import { verifyAccessToken } from "../utils/jwt.js";

export const verifyToken = (req, res, next) => {
  try {
    const authHeader = req.headers.authorization;
    if (!authHeader || !authHeader.startsWith("Bearer")) {
      return res.status(401).json({ error: "No token provided" });
    }
    const token = authHeader.split(" ")[1];
    const payload = verifyAccessToken(token);
    // attach user info to req.user
    req.user = { 
      user_id: payload.sub,
      role: payload.role,
      email: payload.email,  
    };
    return next();
  } catch (err) {
    return res.status(401).json({ error: "Invalid or expired token" });
  }
};
