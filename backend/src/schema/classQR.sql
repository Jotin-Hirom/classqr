-- USERS
CREATE TABLE IF NOT EXISTS users (
    user_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email TEXT UNIQUE NOT NULL,
    password_hash TEXT,
    role TEXT CHECK(role IN ('student','teacher','admin')) NOT NULL,
    created_at TIMESTAMP DEFAULT NOW()
);

-- STUDENTS
CREATE TABLE IF NOT EXISTS students (
    user_id UUID PRIMARY KEY REFERENCES users(user_id) ON DELETE CASCADE,
    roll_no TEXT UNIQUE NOT NULL,
    sname TEXT NOT NULL,
    semester INT CHECK(semester BETWEEN 1 AND 10),
    programme TEXT ,
    batch INT,
    photo_url TEXT 
);

-- TEACHERS
CREATE TABLE IF NOT EXISTS teachers (
    user_id UUID PRIMARY KEY REFERENCES users(user_id) ON DELETE CASCADE,
    abbr TEXT UNIQUE NOT NULL,
    tname TEXT NOT NULL,
    designation TEXT,
    specialization TEXT, 
    dept TEXT,
    photo_url TEXT
);

-- SUBJECTS
CREATE TABLE IF NOT EXISTS subjects (
    sub_code TEXT PRIMARY KEY,
    sub_name TEXT NOT NULL
);

-- COURSE OFFERINGS
CREATE TABLE IF NOT EXISTS course_offerings (
    course_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    teacher_id UUID REFERENCES teachers(user_id),
    sub_code TEXT REFERENCES subjects(sub_code),
    semester INT,
    programme TEXT,
    created_at TIMESTAMP DEFAULT NOW()
);

-- STUDENT ENROLLMENTS
CREATE TABLE IF NOT EXISTS student_enrollments (
    enrollment_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    student_id UUID REFERENCES students(user_id),
    course_id UUID REFERENCES course_offerings(course_id),
    UNIQUE(student_id, course_id)
);

-- QR SESSIONS
CREATE TABLE IF NOT EXISTS qr_sessions (
    qr_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    course_id UUID REFERENCES course_offerings(course_id),
    location_created_from TEXT,
    timespan_seconds INT NOT NULL,
    created_at TIMESTAMP DEFAULT NOW(),
    expires_at TIMESTAMP,
    scan_count INT DEFAULT 0
);

-- SCAN EVENTS
CREATE TABLE IF NOT EXISTS scan_events (
    scan_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    qr_id UUID REFERENCES qr_sessions(qr_id),
    student_id UUID REFERENCES students(user_id),
    scan_time TIMESTAMP DEFAULT NOW(),
    device_fingerprint TEXT,
    device_meta JSONB,
    ip_address TEXT,
    geo TEXT,
    token_age_seconds INT,
    ml_score DOUBLE PRECISION,
    status TEXT DEFAULT 'new',
    created_at TIMESTAMP DEFAULT NOW()
);

-- ATTENDANCE
CREATE TABLE IF NOT EXISTS attendance (
    attendance_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    scan_id UUID UNIQUE REFERENCES scan_events(scan_id),
    student_id UUID REFERENCES students(user_id),
    course_id UUID REFERENCES course_offerings(course_id),
    status TEXT CHECK(status IN ('present','absent')),
    scanned_time TIMESTAMP,
    photo_url TEXT,
    location_scanned_from TEXT,
    date DATE NOT NULL
);

-- VERIFICATION LOGS
CREATE TABLE IF NOT EXISTS verification_logs (
    verify_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    scan_id UUID REFERENCES scan_events(scan_id),
    teacher_id UUID REFERENCES teachers(user_id),
    verification_time TIMESTAMP DEFAULT NOW(),
    result TEXT CHECK(result IN ('accepted','rejected')),
    comment TEXT
);

-- REPORTS
CREATE TABLE IF NOT EXISTS reports (
    report_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    teacher_id UUID REFERENCES teachers(user_id),
    course_id UUID REFERENCES course_offerings(course_id),
    report_type TEXT,
    generated_at TIMESTAMP DEFAULT NOW(),
    file_url TEXT
);


-- REFRESH TOKENS
CREATE TABLE IF NOT EXISTS refresh_tokens (
  token_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES users(user_id) ON DELETE CASCADE,
  token_hash TEXT ,
  expires_at TIMESTAMP NOT NULL,
  revoked BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMP DEFAULT NOW()
);

