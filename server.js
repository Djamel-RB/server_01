// =================== استيراد الحزم ===================
import express from 'express';
import cors from 'cors';
import dotenv from 'dotenv';
import { createClient } from '@supabase/supabase-js';

dotenv.config();

// =================== إنشاء نسخة من Express ===================
const app = express();

// =================== تفعيل CORS و JSON ===================
app.use(cors());
app.use(express.json());

// =================== إعداد الاتصال بـ Supabase ===================
const supabase = createClient(
  process.env.SUPABASE_URL,
  process.env.SUPABASE_KEY
);

////////////////////////// AUTH ROUTES //////////////////////////

// REGISTER - إنشاء حساب عبر Supabase Auth + تخزين معلومات الجدول users
app.post('/register', async (req, res) => {
  const { email, password, first_name, last_name, phone_number, role } = req.body;

  console.log('Received data:', req.body);

  // 1️⃣ إنشاء حساب عبر Supabase Auth
  const { data: authData, error: authError } = await supabase.auth.signUp({
    email,
    password,
    options: {
      data: {
        first_name,
        last_name,
      },
    },
  });

  if (authError) {
    console.error('Auth error:', authError);
    return res.status(400).json({ error: authError.message }); 
  }

  // 2️⃣ تخزين معلومات الجدول public.users
  const { data: userData, error: userError } = await supabase
    .from('users') // ✅ الجدول بالأحرف الصغيرة
    .insert({
      user_id: authData.user.id,
      first_name,
      last_name,
      email,
      phone_number,
      role: role || 'Patient',
    })
    .select()
    .single();

  if (userError) {
    console.error('User table error:', userError);
    return res.status(400).json({ error: userError.message }); 
  }

  // ✅ الرد على الطلب
  res.json({ auth: authData, user: userData }); 
});

// LOGIN - تسجيل الدخول عبر Supabase Auth
app.post('/login', async (req, res) => {
  const { email, password } = req.body;

  // محاوله تسجيل الدخول
  const { data, error } = await supabase.auth.signInWithPassword({ email, password });
  
  if (error) {
    console.error('Login error:', error);
    return res.status(400).send({ error: error.message }); 
  }

  res.json(data);
});



// أضف هذا المسار قبل app.listen()
app.get('/auth/callback', async (req, res) => {
  const { access_token, refresh_token } = req.query;
  
  if (!access_token || !refresh_token) {
    return res.status(400).send('Missing tokens');
  }

  // تعيين الجلسة
  const { data, error } = await supabase.auth.setSession({
    access_token,
    refresh_token
  });

  if (error) {
    return res.status(400).send(`Auth failed: ${error.message}`);
  }

  res.redirect('/profile'); // أو أي صفحة تريد توجيه المستخدم إليها
});
////////////////////////// START SERVER //////////////////////////
const PORT = process.env.PORT || 3000;

app.listen(PORT, () => {
  console.log(`✅ Server running on http://localhost:${PORT}`);
});
