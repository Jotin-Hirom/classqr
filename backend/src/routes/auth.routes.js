import express from "express";
import { registerUser, login, refreshToken, logoutUser, logoutAllDevices } from "../controllers/auth.controller.js";
import { verifyToken } from "../middlewares/auth.middleware.js";
const router = express.Router();

/**
 * POST /api/auth/signup
 * Body must include "role" = 'student' | 'teacher' and the required fields per role.
 */

// Signup (existing)
router.post("/signup", registerUser);

// Login -> returns access token + sets refresh cookie
router.post("/login", login);

// Refresh endpoint -> reads refresh cookie and returns new access token
router.post("/refresh", refreshToken);

// Logout -> revoke refresh token & clear cookie
router.post("/logout", verifyToken ,logoutUser);

// Logout from ALL devices (new). Uses verifyToken when available.
router.post("/logoutAll", verifyToken, logoutAllDevices);

// Me endpoint -> get current user info
// router.get("/me", verifyToken, me);

export default router;
