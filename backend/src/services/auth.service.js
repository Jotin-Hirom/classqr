import bcrypt from "bcryptjs";
import { compareSync } from "bcryptjs";
import pool from "../config/pool.js";
import { v4 as uuidv4 } from "uuid";
import { UserModel } from '../models/user.model.js';
// Validators
import {
  isValidName,
  isValidRoll,
  isValidEmailForRoll,
  isValidSemester,
  isValidProgramme,
  isValidBatch,
  isValidPassword,
  // isValidDesignationOrDept,
} from "../utils/validator.js";

// JWT utils
import { signAccessToken, signRefreshToken , hashToken} from "../utils/jwt.js";
import dotenv from "dotenv";
dotenv.config();

/**
 * Helper to throw formatted error
 */
const throwError = (status, message) => {
  const err = new Error(message);
  err.status = status;
  throw err;
};

// Cookie options
const isProduction = process.env.NODE_ENV === "production";
// Cookie name
const cookieOptions = {
  httpOnly: true,
  secure: isProduction,
  sameSite: "Strict",
  // path limits cookie to refresh route if you like:
  path: "/api/auth/refresh",
  //maxAge: undefined, // we set based on REFRESH_EXPIRE when creating cookie below
};


// Generate user_id
const user_id = uuidv4();
// Generate token_id
const token_id = uuidv4();

// compute expires_at for DB and cookie maxAge (ms)
const refreshExpire = process.env.REFRESH_EXPIRE || "1d";

const cookiesName = process.env.COOKIE_NAME || "refreshToken";

/**
 * Create a student user + student profile in a transaction
 * Expects fields: email, password, name (sname), roll_no, semester, programme, batch, photo_url (optional)
 */
export const createStudentUser = async (payload) => {
  // const emailLower = payload.email.toLowerCase();
  // // Extract roll from email
  // const roll = emailLower.split("@")[0];
  const email = payload.email.toLowerCase();
  const semester = parseInt(payload.semester, 10);
  const batch = parseInt(payload.batch, 10);
  const sname = payload.sname;
  const password = payload.password;
  const roll_no = payload.roll_no;
  const programme = payload.programme;
  const photo_url = null; 
 


  // Basic validation
  if (!sname || !isValidName(sname)) throwError(400, "Invalid student name");
  if (!roll_no || !isValidRoll(roll_no)) throwError(400, "Invalid roll_no format (3 letters + 5 digits)");
  if (!email || !isValidEmailForRoll(email, roll_no)) throwError(400, "Email must be roll_no@tezu.ac.in");
  if (!isValidSemester(semester)) throwError(400, "Semester must be an integer between 1 and 10");
  if (!programme || !isValidProgramme(programme)) throwError(400, "Invalid programme (alphabets only)");
  if (!isValidBatch(batch)) throwError(400, "Invalid batch year");
  if (!password || !isValidPassword(password)) throwError(400, "Password does not meet complexity requirements");

  // Hash password
  const salt = await bcrypt.genSalt(10);
  const password_hash = await bcrypt.hash(password, salt);

  // Insert into DB in a transaction
  const client = await pool.connect();
  try {
    await client.query("BEGIN");

    // Insert into users
    const insertUserText = `
      INSERT INTO users (user_id, email, password_hash, role)
      VALUES ($1, $2, $3, 'student')
      RETURNING user_id, email, role, created_at
    `;
    const userRes = await client.query(insertUserText, [user_id, email.toLowerCase(), password_hash]);
    const user = userRes.rows[0];

    // Insert into students
    const insertStudentText = `
      INSERT INTO students (user_id, roll_no, sname, semester, programme, batch, photo_url)
      VALUES ($1, $2, $3, $4, $5, $6, $7)
      RETURNING  user_id, roll_no, sname, semester, programme, batch, photo_url
    `;
    const studentRes = await client.query(insertStudentText, [
      user_id,
      roll_no.toUpperCase() , sname.toUpperCase(), semester, programme.toUpperCase(), batch, photo_url
    ]);
    const student = studentRes.rows[0];

    await client.query("COMMIT");
    return {
      user_id: user.user_id,
      email: user.email,
      role: user.role,
      student_profile: student,
    };
  } catch (err) {
    await client.query("ROLLBACK");
    // Check for unique violations
    if (err.code === "23505") {
      // unique violation
      if (err.detail && err.detail.includes("email")) {
        throwError(409, "Email already exists");
      }
      if (err.detail && err.detail.includes("roll_no")) {
        throwError(409, "Roll number already exists");
      }
      // generic unique
      throwError(409, "Duplicate value"); 
    }
    throw err;
  } finally {
    client.release();
  }
};


/** 
 * Create teacher user + teacher profile
 * Expects fields: email, password, tname, abbr, designation, specialization (opt), dept, programme (opt), photo_url (opt)
 */
export const createTeacherUser = async (payload) => {
  const emailLower = payload.email.toLowerCase();
  const Abbr = emailLower.split("@")[0];
  const tname = payload.tname;
  const abbr = Abbr;
   const email = payload.email;
   const password = payload.password;
   const designation = payload.designation;
   const specialization = payload.specialization;
   const dept = payload.dept;
   const photo_url = null;

 
  // Validation
  if (!tname || !isValidName(tname)) throwError(400, "Invalid teacher name.");
  if (!abbr || typeof abbr !== "string" || abbr.trim().length < 2) throwError(400, "Invalid abbreviation.");
  if (!email || !email.toLowerCase().endsWith("@tezu.ernet.in")) throwError(400, "Email must end with @tezu.ernet.in.");
  // if (!designation || !isValidDesignationOrDept(designation)) throwError(400, "Invalid designation.");
  // if (!dept || !isValidDesignationOrDept(dept)) throwError(400, "Invalid department.");
  if (!password || !isValidPassword(password)) throwError(400, "Password does not meet complexity requirements.");

  // Hash password
  const salt = await bcrypt.genSalt(10);
  const password_hash = await bcrypt.hash(password, salt);

  const client = await pool.connect();
  try {
    await client.query("BEGIN");
    const insertUserText = `
      INSERT INTO users (user_id, email, password_hash, role)
      VALUES ($1, $2, $3, 'teacher')
      RETURNING user_id, email, role
    `;
    const userRes = await client.query(insertUserText, [user_id, email.toLowerCase(), password_hash]);
    const user = userRes.rows[0];

    const insertTeacherText = `
      INSERT INTO teachers (user_id, abbr, tname, designation, specialization, dept, photo_url)
      VALUES ($1, $2, $3, $4, $5, $6, $7)
      RETURNING user_id, abbr, tname, designation, specialization, dept, photo_url
    `;
    const teacherRes = await client.query(insertTeacherText, [
      user.user_id,
      abbr.toUpperCase(),
      tname.toUpperCase(),
      designation,
      specialization,
      dept,
      photo_url,
    ]);
    const teacher = teacherRes.rows[0];

    await client.query("COMMIT");

    return {
      user_id: user.user_id,
      email: user.email,
      role: user.role,
      teacher_profile: teacher,
    };
  } catch (err) {
    await client.query("ROLLBACK");
    if (err.code === "23505") {
      if (err.detail && err.detail.includes("email")) {
        throwError(409, "Email already exists");
      }
      if (err.detail && err.detail.includes("abbr")) {
        throwError(409, "Abbreviation already exists");
      }
      throwError(409, "Duplicate value");
    }
    throw err;
  } finally {
    client.release();
  }
};
 

// Login user: verify credentials, generate tokens, save refresh token
export const loginUser = async ({ email, password }) => {
  const user = await UserModel.getUserByEmail(email.toLowerCase());
  
  if (!user) return res.status(401).json({ error: "User not found." });
  if (!user.password_hash) return res.status(401).json({ error: "Complete registration via provider" });
  
  const valid = compareSync(password, user.password_hash);
  if (!valid) return res.status(401).json({ error: "Invalid credentials" });
  
  const ok = await bcrypt.compare(password, user.password_hash); 
  if (!ok) throw new Error("Invalid credentials");

  // generate tokens
  const accessToken = signAccessToken({ sub: user.user_id, role: user.role, email: user.email });
  const refreshToken = signRefreshToken({ sub: user.user_id });


  // Convert REFRESH_EXPIRE to ms for cookie maxAge:
  const msMap = { 
      s: 1000,         // 1 second = 1000 milliseconds
      m: 60 * 1000,    // 1 minute = 60 seconds × 1000 = 60,000 ms
      h: 3600 * 1000,  // 1 hour = 3600 seconds × 1000 = 3,600,000 ms  
      d: 24 * 3600 * 1000 // 1 day = 24 hours × 3600 seconds × 1000 = 86,400,000 ms
  };
    // naive parse like "7d", "30m"
    const match = refreshExpire.match(/^(\d+)([smhd])$/);
    let cookieMaxAge = null;
    if (match) {
      const n = Number(match[1]);
      const unit = match[2];
      cookieMaxAge = n * (msMap[unit] || msMap.d);
      cookieOptions.maxAge = cookieMaxAge;
    }

    // Save refresh token in DB
    const expiresAt = new Date(Date.now() + (cookieOptions.maxAge || 1 * 24 * 3600 * 1000));
    const token = await saveRefreshToken({
      user_id: user.user_id,
      token: refreshToken,
      expires_at: expiresAt,
    });
  return { cookiesName, accessToken, tokenReceived: token, user: { userId: user.user_id, role: user.role , email:user.email}, cookieOptions };
};


/**
 * Save refresh token
 * tokenObj: { user_id, token, expires_at (Date) }
 */
export const saveRefreshToken = async (tokenObj) => {
  // Hash the token before saving
  const token_hash = await hashToken(tokenObj.token);
  // Save to DB
  const q = `INSERT INTO refresh_tokens (token_id, user_id, token_hash, expires_at) VALUES ($1, $2, $3,$4)`;
  await pool.query(q, [token_id, tokenObj.user_id, token_hash, tokenObj.expires_at]);
  return token_hash;
};


/**
 * Revoke refresh token by token string (used during rotation)
 */
export const revokeRefreshTokenByHash = async (rawToken) => {
  const h = await hashToken(rawToken);
  await pool.query(`UPDATE refresh_tokens SET revoked = TRUE WHERE token_hash = $1`, [h]);
};


/**
 * Revoke ALL refresh tokens for a specific user (optional support)
 */
export const revokeAllUserRefreshTokens = async (user_id) => {
  await pool.query(`UPDATE refresh_tokens SET revoked = TRUE WHERE user_id = $1`, [user_id]);
};



/**
 * Refresh flow (rotation):
 * - client sends raw refresh token
 * - server hashes it and finds DB record where token_hash matches, not revoked, and not expired
 * - if found: revoke it (set revoked=true), issue new refresh token and access token, store new token hash
 */
export const rotateRefreshToken = async (rawToken) => {
  const tokenHash =await hashToken(rawToken);

  const client = await pool.connect();
  try {
    await client.query("BEGIN");
    const selectQ = `SELECT token_id, user_id, revoked, expires_at
                     FROM refresh_tokens
                     WHERE token_hash = $1
                     FOR UPDATE`;
    const sel = await client.query(selectQ, [tokenHash]);
    const row = sel.rows[0];

    if (!row) {
      throw new Error("Invalid refresh token");
    }
    if (row.revoked) throw new Error("Refresh token revoked");
    if (new Date(row.expires_at) < new Date()) throw new Error("Refresh token expired");

    // revoke old token
    const revokeQ = `UPDATE refresh_tokens SET revoked = TRUE WHERE token_id = $1`;
    await client.query(revokeQ, [row.token_id]);

    // create new token
    const { token: newToken, hash: newHash } = createRefreshToken();
    const newExpiresAt = new Date(Date.now() + REFRESH_DAYS * 24 * 60 * 60 * 1000);

    const insertQ = `INSERT INTO refresh_tokens (user_id, token_hash, expires_at)
                     VALUES ($1, $2, $3)`;
    await client.query(insertQ, [row.user_id, newHash, newExpiresAt]);

    // create new access token
    const accessToken = signAccessToken({ userId: row.user_id });

    await client.query("COMMIT");
    return { accessToken, refreshToken: newToken, userId: row.user_id };
  } catch (err) {
    await client.query("ROLLBACK");
    throw err;
  } finally {
    client.release();
  }
};


/**
 * Find refresh token row by token string
 */
export const findRefreshToken = async (token) => {
  
  const q = `
    SELECT token_id, user_id, token_hash, expires_at, revoked
    FROM refresh_tokens
    WHERE user_id = $1 AND revoked = FALSE
    ORDER BY created_at DESC
    LIMIT 1
  `;
  const { rows } = await pool.query(q, [token]);
  return rows[0];
};


// Cleanup old revoked refresh tokens (optional maintenance task)
export const cleanupOldRefreshTokens = async () => {
  const q = `
    DELETE FROM refresh_tokens
    WHERE revoked = TRUE
      AND expires_at < NOW() - INTERVAL '5 days'
  `;
  await pool.query(q);
};