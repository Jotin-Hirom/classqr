export const googleAuth = async (req, res) => {};
export const forgotPassword = async (req, res) => {};
export const verifyOtp = async (req, res) => {};
export const resetPassword = async (req, res) => {};

// Authentication controller for login, refresh, logout
import { loginUser, saveRefreshToken, revokeRefreshTokenByHash, findRefreshToken , revokeAllUserRefreshTokens} from "../services/auth.service.js";
import { signAccessToken, signRefreshToken, verifyRefreshToken } from "../utils/jwt.js";
import pool from "../config/pool.js";
import bcrypt from "bcryptjs";


// Registration controller
import { createStudentUser, createTeacherUser } from "../services/auth.service.js";

import env from "dotenv";
env.config();

const COOKIE_NAME = process.env.REFRESH_COOKIE_NAME || "refreshToken";

/**
 * Register user (student or teacher)
 * Expects JSON body with "role" field.
 */
export const registerUser = async (req, res, next) => {
  try {
    const { role } = req.body;
    if (!role || (role !== "student" && role !== "teacher")) {
      return res.status(400).json({ error: "role must be 'student' or 'teacher'" });
    }

    if (role === "student") {
      const result = await createStudentUser(req.body);
      return res.status(201).json({ message: "Student registered", user: result });
    } else {
      const result = await createTeacherUser(req.body);
      return res.status(201).json({ message: "Teacher registered", user: result });
    }
  } catch (err) {
    // Known errors thrown from service include { status, message }
    if (err && err.status) {
      return res.status(err.status).json({ error: err.message });
    }
    next(err);
  }
};

// Login controller
export const login = async (req, res) => {
  try {
    const { email, password } = req.body;
    // Basic validation for user to login
    if (!email || !password) return res.status(400).json({ error: "Email and password required" });
    // Authenticate user (from service)
    const {COOKIE_NAME, accessToken, tokenReceived, user, cookieOptions } = await loginUser({ email, password });
    // set httpOnly cookie with raw refresh token
    res.cookie(COOKIE_NAME, tokenReceived, cookieOptions);
    res.json({ success: true, accessToken, user });
  } catch (err) {
    res.status(401).json({ success: false, message: err.message });
  }
};

// Refresh token controller
export const refreshToken = async (req, res, next) => {
  try {
    const token = req.cookies?.[COOKIE_NAME] || req.body?.[COOKIE_NAME];
    if (!token) return res.status(401).json({ error: "Refresh token missing" });

    // verify signature
    let payload;
    try {
      payload = verifyRefreshToken(token);
    } catch (e) {
      return res.status(401).json({ error: "Invalid refresh token" });
    }

    // Lookup stored hashed token for this user
    const stored = await findRefreshToken(payload.sub);
    if (!stored) return res.status(401).json({ error: "No valid refresh token found" });

    if (new Date(stored.expires_at) < new Date()) {
      return res.status(401).json({ error: "Refresh token expired" });
    }

    // Compare hashed vs plaintext token
    const tokenMatch = await bcrypt.compare(token, stored.token_hash);
    if (!tokenMatch) return res.status(401).json({ error: "Refresh token mismatch" });

    // ROTATE TOKEN: revoke old one
    await revokeRefreshTokenByHash(stored.token_id);
     // 3. ROTATE TOKEN → revoke old + issue new refresh token
    const newRefreshToken = signRefreshToken({ sub: payload.sub });

    // Calculate expiry date
    const refreshExpire = process.env.REFRESH_EXPIRE || "7d";
    const msMap = { s: 1000, m: 60000, h: 3600000, d: 86400000 };
    const match = refreshExpire.match(/^(\d+)([smhd])$/);
    let cookieMaxAge = 7 * 86400000;
    if (match) cookieMaxAge = Number(match[1]) * msMap[match[2]];

    const expiresAt = new Date(Date.now() + cookieMaxAge);

    // Revoke old token
    await revokeRefreshTokenByHash(token);

    // Save new token
    await saveRefreshToken({
      user_id: stored.user_id,
      token_hash: newRefreshToken,
      expires_at: expiresAt,
    });

    // Set cookie
    res.cookie(COOKIE_NAME, newRefreshToken, {
      httpOnly: true,
      secure: process.env.NODE_ENV === "production",
      sameSite: "Strict",
      maxAge: cookieMaxAge,
    });

    // All good -> issue new access token (optionally rotate refresh tokens)
    const accessToken = signAccessToken({ sub: stored.user_id, role: req.body?.role || undefined });

    return res.json({ accessToken, expiresIn: process.env.JWT_EXPIRE || "15m",rotated: true });
  } catch (err) {
    next(err);
  }
};

// Logout controller
export const logoutUser = async (req, res, next) => {
  console.log(req.body);
  try {
    const refreshToken = req.cookies?.refreshToken || req.body?.refreshToken;

    if (refreshToken) {
      let payload;
      try {
        payload = verifyRefreshToken(refreshToken);
        // Revoke all refresh tokens for this user
        await revokeRefreshTokenByHash(payload.sub);
      } catch (e) {
        // ignore invalid token — just clear cookie
      }
    }
    res.clearCookie(COOKIE_NAME, {
      httpOnly: true,
      secure: process.env.NODE_ENV === "production",
      sameSite: "Strict",
    });

    return res.json({ success: true, message: "Logged out" });
  } catch (err) {
    next(err);
  }
};


/**
 * POST /api/auth/logoutAll
 * - If Authorization Bearer token present (verifyToken middleware), uses req.user.user_id
 * - Otherwise, attempts to read refresh cookie, verify it, and use the sub to revoke
 */
export const logoutAllDevices = async (req, res, next) => {
  try {
    let userId = null;

    // 1) Prefer the authenticated user info (verifyToken middleware)
    if (req.user && req.user.user_id) {
      userId = req.user.user_id;
    } else {
      // 2) Fallback to refresh cookie if no access token present
      const refreshToken = req.cookies?.refreshToken || req.body?.refreshToken;
      if (!refreshToken) {
        return res.status(401).json({ error: "No credentials provided to identify user." });
      }
      try {
        const payload = verifyRefreshToken(refreshToken);
        userId = payload.sub;
      } catch (err) {
        return res.status(401).json({ error: "Invalid refresh token" });
      }
    }

    // Revoke all refresh tokens for the user
    await revokeAllUserRefreshTokens(userId);

    // Clear cookie on client
    res.clearCookie(COOKIE_NAME, {
      httpOnly: true,
      secure: process.env.NODE_ENV === "production",
      sameSite: "Strict",
    });
    return res.json({ success: true, message: "Logged out from all devices" });
  } catch (err) {
    next(err);
  }
};









 

// Me controller
// export const me = async (req, res, next) => {
//   try {
//     const userId = req.user.user_id;   // added by verifyToken middleware
//     const role = req.user.role;

//     // 1. Fetch base user info
//     const userQuery = `
//       SELECT user_id, email, role, created_at
//       FROM users
//       WHERE user_id = $1
//       LIMIT 1
//     `;
//     const userRes = await pool.query(userQuery, [userId]);
//     const user = userRes.rows[0];
//     if (!user) return res.status(404).json({ error: "User not found" });

//     // 2. Load profile based on role
//     let profile = null;

//     if (role === "student") {
//       const q = `
//         SELECT user_id, roll_no, sname, semester, programme, batch, photo_url
//         FROM students
//         WHERE user_id = $1
//         LIMIT 1
//       `;
//       const r = await pool.query(q, [userId]);
//       profile = r.rows[0] || {};
//     }

//     if (role === "teacher") {
//       const q = `
//         SELECT user_id, abbr, tname, designation, specialization, dept, programme, photo_url
//         FROM teachers
//         WHERE user_id = $1
//         LIMIT 1
//       `;
//       const r = await pool.query(q, [userId]);
//       profile = r.rows[0] || {};
//     }

//     // Admins don't have separate profile tables — return basic data only

//     return res.json({
//       user,
//       profile,
//     });

//   } catch (err) {
//     next(err);
//   }
// };

