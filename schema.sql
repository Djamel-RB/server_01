-- جدول المستخدمين لتخزين البيانات الأساسية لكل مستخدم في النظام
-- Contient les informations de base pour chaque utilisateur dans le système (avec erreurs)
CREATE TABLE Users (
    user_id VARCHAR(50) PRIMARY KEY, -- معرف المستخدم الفريد من Firebase Authentication
                                     -- ID unique de l'utilisateur depuis Firebase Authentification
    first_name VARCHAR(50) NOT NULL, -- الاسم الأول للمستخدم
                                     -- Nom de l'utilisateur
    last_name VARCHAR(50) NOT NULL,  -- اسم العائلة للمستخدم
                                     -- Nom de famille de utilisateur
    email VARCHAR(100) UNIQUE NOT NULL, -- البريد الإلكتروني، يجب أن يكون فريدًا
                                        -- Email, doit être unique
    phone_number VARCHAR(20) UNIQUE NOT NULL, -- رقم الهاتف، يجب أن يكون فريدًا
                                             -- Numéro de téléphone, unique
    profile_picture VARCHAR(255), -- رابط صورة الملف الشخصي (اختياري)
                                  -- URL de la photo de profil (optionnel)
    role VARCHAR(20) DEFAULT 'Patient' NOT NULL CHECK (role IN ('Patient', 'Doctor', 'Pharmacist', 'HospitalAdmin', 'SystemAdmin')),
                                  -- دور المستخدم، الافتراضي هو "مريض"، يمكن أن يكون طبيب، صيدلي، مدير مستشفى، أو أدمن
                                  -- Rôle de l'utilisateur, par défaut "Patient", peut être Docteur, Pharmacien, Admin Hôpital, ou Admin Système
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, -- تاريخ إنشاء الحساب
                                                   -- Date de création du compte
    updated_at TIMESTAMP -- تاريخ آخر تحديث للبيانات
                         -- Dernière mise à jour des données
);

-- جدول لتخزين طلبات تغيير الأدوار (مثل طلب أن يصبح المستخدم طبيبًا أو صيدليًا)
-- Table pour stocker les demandes de changement de rôle (exemple: devenir docteur ou pharmacien)
CREATE TABLE RoleRequests (
    request_id SERIAL PRIMARY KEY, -- ID unique de la demande
    user_id VARCHAR(50) NOT NULL, -- معرف المستخدم الذي يطلب تغيير الدور
    requested_role VARCHAR(20) NOT NULL CHECK (requested_role IN ('Doctor', 'Pharmacist', 'HospitalAdmin')),
    legal_documents VARCHAR(255) NOT NULL, -- رابط ملف الوثائق القانونية
    status VARCHAR(20) DEFAULT 'Pending' CHECK (status IN ('Pending', 'Approved', 'Rejected')),
    submitted_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, -- تاريخ تقديم الطلب
    reviewed_at TIMESTAMP, -- تاريخ مراجعة الطلب
    admin_id VARCHAR(50), -- معرف الأدمن الذي يراجع الطلب
    FOREIGN KEY (user_id) REFERENCES Users(user_id),
    FOREIGN KEY (admin_id) REFERENCES Users(user_id)
);

CREATE TABLE Doctors (
    doctor_id VARCHAR(50) PRIMARY KEY, -- معرف الطبيب (نفس user_id من جدول Users)
    -- ID du docteur (même que user_id dans Users)
    specialty VARCHAR(100) NOT NULL, -- التخصص الطبي (مثل جراحة، أطفال)
                                     -- Spécialité médicale (exemple: chirurgie, pédiatrie)
    location VARCHAR(255), -- موقع العمل (مثل إحداثيات GPS أو عنوان)
                           -- Localisation du travail (exemple: coordonnées GPS ou adresse)
    work_hours JSON, -- ساعات العمل (مخزنة كـ JSON لمرونة التخزين)
                     -- Heures de travail (stocké en JSON pour flexibilité)
    FOREIGN KEY (doctor_id) REFERENCES Users(user_id) -- ربط مع جدول المستخدمين
);
-- جدول لتخزين بيانات المستشفيات
-- Table pour stocker les données des hôpitaux
CREATE TABLE Hospitals (
    hospital_id SERIAL PRIMARY KEY, -- معرف المستشفى الفريد
    name VARCHAR(100) NOT NULL, -- اسم المستشفى
    location VARCHAR(255) NOT NULL, -- موقع المستشفى
    services JSON, -- الخدمات المتوفرة
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, -- تاريخ الإنشاء
    updated_at TIMESTAMP -- تاريخ آخر تحديث
);

-- جدول وسيط لربط مديري المستشفيات بالمستشفيات (دعم إدارة أكثر من مستشفى)
-- Table pour lier les admins d'hôpitaux aux hôpitaux (supporte plusieurs hôpitaux)
CREATE TABLE HospitalAdmins (
    hospital_admin_id  SERIAL PRIMARY KEY, -- معرف فريد للربط
                                                     -- ID unique pour la liaison
    user_id VARCHAR(50) NOT NULL, -- معرف مدير المستشفى (من جدول Users)
                                  -- ID de l'admin d'hôpital (de la table Users)
    hospital_id INT NOT NULL, -- معرف المستشفى (من جدول Hospitals)
                              -- ID de l'hôpital (de la table Hospitals)
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, -- تاريخ الربط
                                                   -- Date de liaison
    FOREIGN KEY (user_id) REFERENCES Users(user_id), -- ربط مع جدول المستخدمين
    FOREIGN KEY (hospital_id) REFERENCES Hospitals(hospital_id) -- ربط مع جدول المستشفيات
);
-- جدول لتخزين بيانات الصيدليات
-- Table pour stocker les données des pharmacies
CREATE TABLE Pharmacies (
    pharmacy_id SERIAL PRIMARY KEY, -- معرف الصيدلية الفريد
                                               -- ID unique de la pharmacie
    name VARCHAR(100) NOT NULL, -- اسم الصيدلية
                                -- Nom de la pharmacie
    location VARCHAR(255) NOT NULL, -- موقع الصيدلية (مثل إحداثيات GPS)
                                    -- Localisation de la pharmacie (exemple: coordonnées GPS)
    pharmacist_id VARCHAR(50) NOT NULL, -- معرف الصيدلي (من جدول Users)
                                       -- ID du pharmacien (de la table Users)
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, -- تاريخ إنشاء الصيدلية
                                                   -- Date de création de la pharmacie
    updated_at TIMESTAMP, -- تاريخ آخر تحديث
                          -- Dernière mise à jour
    FOREIGN KEY (pharmacist_id) REFERENCES Users(user_id) -- ربط مع جدول المستخدمين
);
-- جدول لتخزين مخزون الأدوية في الصيدليات
-- Table pour stocker l'inventaire des médicaments dans les pharmacies
CREATE TABLE Inventory (
    inventory_id SERIAL PRIMARY KEY, 
    -- معرف فريد لسجل المخزون-- ID unique pour l'enregistrement d'inventaire
    pharmacy_id INT NOT NULL, -- معرف الصيدلية (من جدول Pharmacies)
                              -- ID de la pharmacie (de la table Pharmacies)
    medicine_name VARCHAR(100) NOT NULL, -- اسم الدواء
                                        -- Nom du médicament
    quantity INT NOT NULL, -- الكمية المتوفرة
                           -- Quantité disponible
    type VARCHAR(50), -- نوع الدواء (مثل حبوب، شراب)
                      -- Type de médicament (exemple: comprimés, sirop)
    added_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, -- تاريخ إضافة الدواء
                                                 -- Date d'ajout du médicament
    updated_at TIMESTAMP, -- تاريخ آخر تحديث للمخزون
                          -- Dernière mise à jour de l'inventaire
    FOREIGN KEY (pharmacy_id) REFERENCES Pharmacies(pharmacy_id) -- ربط مع جدول الصيدليات
);


-- جدول لتخزين الأدوية المتبرع بها للصيدليات
-- Table pour stocker les médicaments donnés aux pharmacies
CREATE TABLE Donations (
    donation_id SERIAL PRIMARY KEY, -- معرف فريد للتبرع
                                               -- ID unique pour le don
    pharmacy_id INT NOT NULL, -- معرف الصيدلية التي تتلقى التبرع
                              -- ID de la pharmacie qui reçoit le don
    medicine_name VARCHAR(100) NOT NULL, -- اسم الدواء المتبرع به
                                        -- Nom du médicament donné
    quantity INT NOT NULL, -- الكمية المتبرع بها
                           -- Quantité donnée
    donor_id VARCHAR(50), -- معرف المتبرع (من جدول Users، اختياري)
                          -- ID du donateur (de la table Users, optionnel)
    donated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, -- تاريخ التبرع
                                                   -- Date du don
    FOREIGN KEY (pharmacy_id) REFERENCES Pharmacies(pharmacy_id), -- ربط مع جدول الصيدليات
    FOREIGN KEY (donor_id) REFERENCES Users(user_id) -- ربط مع جدول المستخدمين
);
-- جدول لتخزين طلبات المواعيد بين المرضى والأطباء
-- Table pour stocker les demandes de rendez-vous entre patients et docteurs
CREATE TABLE Appointments (
    appointment_id SERIAL PRIMARY KEY, -- معرف الموعد الفريد
                                                  -- ID unique du rendez-vous
    patient_id VARCHAR(50) NOT NULL, -- معرف المريض (من جدول Users)
                                     -- ID du patient (de la table Users)
    doctor_id VARCHAR(50) NOT NULL, -- معرف الطبيب (من جدول Users)
                                    -- ID du docteur (de la table Users)
    hospital_id INT, -- معرف المستشفى (إن كان الموعد في مستشفى، اختياري)
                     -- ID de l'hôpital (si le rendez-vous est dans un hôpital, optionnel)
    appointment_date TIMESTAMP NOT NULL, -- تاريخ ووقت الموعد
                                       -- Date et heure du rendez-vous
    status VARCHAR(20) DEFAULT 'Pending' CHECK (status IN ('Pending', 'Approved', 'Rejected', 'Rescheduled')),
                                       -- حالة الموعد (قيد الانتظار، مقبول، مرفوض، إعادة جدولة)
                                       -- Statut du rendez-vous (En attente, Approuvé, Rejeté, Reprogrammé)
    proposed_date TIMESTAMP, -- تاريخ مقترح (إذا اقترح الطبيب موعدًا آخر)
                            -- Date proposée (si le docteur propose une autre date)
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, -- تاريخ إنشاء طلب الموعد
                                                   -- Date de création de la demande
    FOREIGN KEY (patient_id) REFERENCES Users(user_id), -- ربط مع جدول المستخدمين (المريض)
    FOREIGN KEY (doctor_id) REFERENCES Users(user_id), -- ربط مع جدول المستخدمين (الطبيب)
    FOREIGN KEY (hospital_id) REFERENCES Hospitals(hospital_id) -- ربط مع جدول المستشفيات
    );
-- جدول لتخزين الرسائل بين المستخدمين (مرضى، أطباء، صيادلة)
-- Table pour stocker les messages entre utilisateurs (patients, docteurs, pharmaciens)
CREATE TABLE Messages (
    message_id SERIAL PRIMARY KEY, -- معرف الرسالة الفريد
                                              -- ID unique du message
    sender_id VARCHAR(50) NOT NULL, -- معرف المرسل (من جدول Users)
                                    -- ID de l'expéditeur (de la table Users)
    receiver_id VARCHAR(50) NOT NULL, -- معرف المستلم (من جدول Users)
                                      -- ID du destinataire (de la table Users)
    subject VARCHAR(255), -- عنوان الرسالة (اختياري)
                          -- Sujet du message (optionnel)
    content TEXT NOT NULL, -- محتوى الرسالة
                           -- Contenu du message
    attachment VARCHAR(255), -- رابط الملف المرفق (مثل PDF، اختياري)
                             -- URL du fichier joint (exemple: PDF, optionnel)
    sent_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, -- تاريخ إرسال الرسالة
                                                -- Date d'envoi du message
    FOREIGN KEY (sender_id) REFERENCES Users(user_id), -- ربط مع جدول المستخدمين (المرسل)
    FOREIGN KEY (receiver_id) REFERENCES Users(user_id) -- ربط مع جدول المستخدمين (المستلم)
);
-- جدول لتخزين تقييمات المرضى للأطباء
-- Table pour stocker les évaluations des patients pour les docteurs
CREATE TABLE Ratings (
    rating_id SERIAL PRIMARY KEY, -- معرف التقييم الفريد
                                             -- ID unique de l'évaluation
    patient_id VARCHAR(50) NOT NULL, -- معرف المريض الذي يقيم (من جدول Users)
                                     -- ID du patient qui évalue (de la table Users)
    doctor_id VARCHAR(50) NOT NULL, -- معرف الطبيب المقيم (من جدول Users)
                                    -- ID du docteur évalué (de la table Users)
    rating INT NOT NULL CHECK (rating BETWEEN 1 AND 5), -- التقييم (من 1 إلى 5)
                                                       -- Évaluation (de 1 à 5)
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, -- تاريخ التقييم
                                                   -- Date de l'évaluation
    FOREIGN KEY (patient_id) REFERENCES Users(user_id), -- ربط مع جدول المستخدمين (المريض)
    FOREIGN KEY (doctor_id) REFERENCES Users(user_id) -- ربط مع جدول المستخدمين (الطبيب)
);
-- جدول لتخزين طلبات انضمام الأطباء إلى المستشفيات
-- Table pour stocker les demandes d'adhésion des docteurs aux hôpitaux
CREATE TABLE HospitalDoctorRequests (
    request_id SERIAL PRIMARY KEY, -- معرف الطلب الفريد
                                              -- ID unique de la demande
    doctor_id VARCHAR(50) NOT NULL, -- معرف الطبيب (من جدول Users)
                                    -- ID du docteur (de la table Users)
    hospital_id INT NOT NULL, -- معرف المستشفى (من جدول Hospitals)
                              -- ID de l'hôpital (de la table Hospitals)
    status VARCHAR(20) DEFAULT 'Pending' CHECK (status IN ('Pending', 'Approved', 'Rejected')),
                              -- حالة الطلب (قيد الانتظار، مقبول، مرفوض)
                              -- Statut de la demande (En attente, Approuvé, Rejeté)
    submitted_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, -- تاريخ تقديم الطلب
                                                     -- Date de soumission de la demande
    FOREIGN KEY (doctor_id) REFERENCES Users(user_id), -- ربط مع جدول المستخدمين
    FOREIGN KEY (hospital_id) REFERENCES Hospitals(hospital_id) -- ربط مع جدول المستشفيات
);
-- جدول لتخزين الإشعارات (مثل نفاد المخزون أو تغيير موعد)
-- Table pour stocker les notifications (exemple: rupture de stock ou changement de rendez-vous)
CREATE TABLE Notifications (
    notification_id SERIAL PRIMARY KEY, -- معرف الإشعار الفريد
    -- ID unique de la notification
    user_id VARCHAR(50) NOT NULL, -- معرف المستخدم الذي يتلقى الإشعار
                                  -- ID de l'utilisateur qui reçoit la notification
    content TEXT NOT NULL, -- محتوى الإشعار
                           -- Contenu de la notification
    type VARCHAR(50) NOT NULL, -- نوع الإشعار (مثل Inventory، Appointment)
                               -- Type de notification (exemple: Inventaire, Rendez-vous)
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, -- تاريخ الإشعار
                                                   -- Date de la notification
    FOREIGN KEY (user_id) REFERENCES Users(user_id) -- ربط مع جدول المستخدمين
);

-- جدول لتخزين الإحصائيات للأدمن (مثل عدد المرضى، الأطباء)
-- Table pour stocker les statistiques pour l'admin (exemple: nombre de patients, docteurs)
CREATE TABLE Statistics (
    stat_id SERIAL PRIMARY KEY, -- معرف الإحصائية الفريد
                                            -- ID unique de la statistique
    entity_type VARCHAR(50) NOT NULL, -- نوع الكيان (مثل Doctor، Pharmacist، Patient)
                                      -- Type d'entité (exemple: Docteur, Pharmacien, Patient)
    entity_id VARCHAR(50) NOT NULL, -- معرف الكيان (مثل user_id أو pharmacy_id)
                                    -- ID de l'entité (exemple: user_id ou pharmacy_id)
    stat_name VARCHAR(100) NOT NULL, -- اسم الإحصائية (مثل عدد المواعيد)
                                     -- Nom de la statistique (exemple: nombre de rendez-vous)
    stat_value INT NOT NULL, -- قيمة الإحصائية
                             -- Valeur de la statistique
    recorded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, -- تاريخ تسجيل الإحصائية
                                                    -- Date d'enregistrement de la statistique
    FOREIGN KEY (entity_id) REFERENCES Users(user_id) -- ربط مع جدول المستخدمين (إن كان الكيان مستخدمًا)
);
-- جدول لتخزين تعليقات المرضى على الأطباء
-- Table pour stocker les commentaires des patients sur les docteurs
CREATE TABLE Comments (
    comment_id SERIAL PRIMARY KEY, -- معرف التعليق الفريد
                                              -- ID unique du commentaire
    patient_id VARCHAR(50) NOT NULL, -- معرف المريض الذي كتب التعليق (من جدول Users)
                                     -- ID du patient qui a écrit le commentaire (de la table Users)
    doctor_id VARCHAR(50) NOT NULL, -- معرف الطبيب الذي يتم التعليق عليه (من جدول Users)
                                    -- ID du docteur commenté (de la table Users)
    comment_text TEXT NOT NULL, -- نص التعليق
                                -- Texte du commentaire
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, -- تاريخ كتابة التعليق
                                                   -- Date de création du commentaire
    FOREIGN KEY (patient_id) REFERENCES Users(user_id), -- ربط مع جدول المستخدمين (المريض)
    FOREIGN KEY (doctor_id) REFERENCES Users(user_id) -- ربط مع جدول المستخدمين (الطبيب)
);
-- جدول لتخزين الخدمات الطبية التي تقدمها المستشفيات
-- Table pour stocker les services médicaux offerts par les hôpitaux
CREATE TABLE MedicalServices (
    service_id SERIAL PRIMARY KEY, -- معرف الخدمة الفريد
                                              -- ID unique du service
    hospital_id INT NOT NULL, -- معرف المستشفى التي تقدم الخدمة (من جدول Hospitals)
                              -- ID de l'hôpital qui offre le service (de la table Hospitals)
    service_name VARCHAR(100) NOT NULL, -- اسم الخدمة (مثل الأشعة، التدليك)
                                       -- Nom du service (exemple: radiologie, massage)
    description TEXT, -- وصف الخدمة (اختياري)
                      -- Description du service (optionnel)
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, -- تاريخ إضافة الخدمة
    -- Date d'ajout du service
    updated_at TIMESTAMP, -- تاريخ آخر تحديث للخدمة
                          -- Dernière mise à jour du service
    FOREIGN KEY (hospital_id) REFERENCES Hospitals(hospital_id) -- ربط مع جدول المستشفيات
);
-- جدول لتخزين أوقات توفر الأطباء للحجوزات
-- Table pour stocker les disponibilités des docteurs pour les rendez-vous
CREATE TABLE DoctorAvailability (
    availability_id SERIAL PRIMARY KEY, -- معرف التوفر الفريد
                                                   -- ID unique de la disponibilité
    doctor_id VARCHAR(50) NOT NULL, -- معرف الطبيب (من جدول Users)
                                    -- ID du docteur (de la table Users)
    hospital_id INT, -- معرف المستشفى (إن كان التوفر في مستشفى، اختياري)
                     -- ID de l'hôpital (si disponibilité dans un hôpital, optionnel)
    day_of_week VARCHAR(10) NOT NULL CHECK (day_of_week IN ('Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday')),
                                    -- يوم الأسبوع
                                    -- Jour de la semaine
    start_time TIME NOT NULL, -- وقت بداية التوفر
                              -- Heure de début de disponibilité
    end_time TIME NOT NULL, -- وقت نهاية التوفر
                            -- Heure de fin de disponibilité
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, -- تاريخ إضافة التوفر
                                                   -- Date d'ajout de la disponibilité
    updated_at TIMESTAMP, -- تاريخ آخر تحديث
                          -- Dernière mise à jour
    FOREIGN KEY (doctor_id) REFERENCES Users(user_id), -- ربط مع جدول المستخدمين
    FOREIGN KEY (hospital_id) REFERENCES Hospitals(hospital_id) -- ربط مع جدول المستشفيات
);
-- جدول لتخزين الوصفات الطبية التي يصدرها الأطباء
-- Table pour stocker les prescriptions médicales émises par les docteurs
CREATE TABLE Prescriptions (
    prescription_id SERIAL PRIMARY KEY, -- معرف الوصفة الفريد
                                                   -- ID unique de la prescription
    doctor_id VARCHAR(50) NOT NULL, -- معرف الطبيب الذي أصدر الوصفة (من جدول Users)
                                    -- ID du docteur qui a émis la prescription (de la table Users)
    patient_id VARCHAR(50) NOT NULL, -- معرف المريض الذي صدرت له الوصفة (من جدول Users)
                                     -- ID du patient pour qui la prescription est émise (de la table Users)
    pharmacy_id INT, -- معرف الصيدلية إذا أُرسلت الوصفة إلى صيدلية (اختياري)
                     -- ID de la pharmacie si la prescription est envoyée à une pharmacie (optionnel)
    medicine_name VARCHAR(100) NOT NULL, -- اسم الدواء
                                        -- Nom du médicament
    dosage VARCHAR(100) NOT NULL, -- الجرعة (مثل "قرص واحد يوميًا")
                                  -- Dosage (exemple: un comprimé par jour)
    instructions TEXT, -- تعليمات إضافية (مثل "تناول بعد الطعام")
                       -- Instructions supplémentaires (exemple: prendre après repas)
    issued_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, -- تاريخ إصدار الوصفة
                                                  -- Date d'émission de la prescription
    FOREIGN KEY (doctor_id) REFERENCES Users(user_id), -- ربط مع جدول المستخدمين (الطبيب)
    FOREIGN KEY (patient_id) REFERENCES Users(user_id), -- ربط مع جدول المستخدمين (المريض)
    FOREIGN KEY (pharmacy_id) REFERENCES Pharmacies(pharmacy_id) -- ربط مع جدول الصيدليات
);
-- جدول لتخزين جداول عمل الأطباء في المستشفيات
-- Table pour stocker les horaires de travail des docteurs dans les hôpitaux
CREATE TABLE DoctorSchedules (
    schedule_id SERIAL PRIMARY KEY, -- معرف الجدول الفريد
                                               -- ID unique de l'horaire
                                               doctor_id VARCHAR(50) NOT NULL, -- معرف الطبيب (من جدول Users)
                                    -- ID du docteur (de la table Users)
    hospital_id INT NOT NULL, -- معرف المستشفى (من جدول Hospitals)
                              -- ID de l'hôpital (de la table Hospitals)
    day_of_week VARCHAR(10) NOT NULL CHECK (day_of_week IN ('Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday')),
                              -- يوم الأسبوع
                              -- Jour de la semaine
    start_time TIME NOT NULL, -- وقت بدء العمل
                              -- Heure de début de travail
    end_time TIME NOT NULL, -- وقت انتهاء العمل
                            -- Heure de fin de travail
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, -- تاريخ إنشاء الجدول
                                                   -- Date de création de l'horaire
    updated_at TIMESTAMP, -- تاريخ آخر تحديث
                          -- Dernière mise à jour
    FOREIGN KEY (doctor_id) REFERENCES Users(user_id), -- ربط مع جدول المستخدمين (الطبيب)
    FOREIGN KEY (hospital_id) REFERENCES Hospitals(hospital_id) -- ربط مع جدول المستشفيات
);
-- جدول لتخزين طلبات الأطباء للوصول إلى التشخيصات السابقة للمرضى
-- Table pour stocker les demandes des docteurs pour accéder aux diagnostics antérieurs des patients
CREATE TABLE DiagnosisAccessRequests (
    request_id INT AUTO_INCREMENT PRIMARY KEY, -- معرف الطلب الفريد
                                              -- ID unique de la demande
    doctor_id VARCHAR(50) NOT NULL, -- معرف الطبيب الذي يطلب الوصول (من جدول Users)
                                    -- ID du docteur qui demande l'accès (de la table Users)
    patient_id VARCHAR(50) NOT NULL, -- معرف المريض صاحب التشخيصات (من جدول Users)
                                     -- ID du patient dont les diagnostics sont demandés (de la table Users)
    status VARCHAR(20) DEFAULT 'Pending' CHECK (status IN ('Pending', 'Approved', 'Rejected')), -- حالة الطلب (قيد الانتظار، مقبول، مرفوض)
                                                                                              -- Statut de la demande (En attente, Approuvé, Rejeté)
    request_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP, -- تاريخ تقديم الطلب
                                                     -- Date de soumission de la demande
    approval_date TIMESTAMP, -- تاريخ الموافقة على الطلب (فارغ إذا لم يُوافق بعد)
                             -- Date d'approbation de la demande (vide si pas encore approuvé)
    expiry_date TIMESTAMP, -- تاريخ انتهاء صلاحية الوصول (أسبوع بعد الموافقة، فارغ إذا لم يُوافق)
                           -- Date d'expiration de l'accès (une semaine après approbation, vide si pas approuvé)
    FOREIGN KEY (doctor_id) REFERENCES Users(user_id), -- ربط مع جدول المستخدمين (الطبيب)
    FOREIGN KEY (patient_id) REFERENCES Users(user_id) -- ربط مع جدول المستخدمين (المريض)
);