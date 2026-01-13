import { PrismaClient } from "@prisma/client";

const prisma = new PrismaClient();

const exercises = [
  // --- TREN SUPERIOR (EXISTING + NEW) ---
  // Pectorales
  {
    name: "Press de Banca con Barra",
    muscleGroup: "Pectorales",
    bodyPart: "Tren Superior",
  },
  {
    name: "Press Inclinado con Mancuernas",
    muscleGroup: "Pectorales",
    bodyPart: "Tren Superior",
  },
  {
    name: "Press Inclinado con Barra",
    muscleGroup: "Pectorales",
    bodyPart: "Tren Superior",
  },
  {
    name: "Press Declinado",
    muscleGroup: "Pectorales",
    bodyPart: "Tren Superior",
  },
  {
    name: "Press de Pecho en Máquina",
    muscleGroup: "Pectorales",
    bodyPart: "Tren Superior",
  },
  {
    name: "Flexiones (Push-ups)",
    muscleGroup: "Pectorales",
    bodyPart: "Tren Superior",
  },
  {
    name: "Flexiones Diamante",
    muscleGroup: "Pectorales",
    bodyPart: "Tren Superior",
  },
  {
    name: "Aperturas con Mancuernas",
    muscleGroup: "Pectorales",
    bodyPart: "Tren Superior",
  },
  {
    name: "Aperturas en Máquina (Peck Deck)",
    muscleGroup: "Pectorales",
    bodyPart: "Tren Superior",
  },
  {
    name: "Cruce de Poleas (Alto)",
    muscleGroup: "Pectorales",
    bodyPart: "Tren Superior",
  },
  {
    name: "Cruce de Poleas (Medio)",
    muscleGroup: "Pectorales",
    bodyPart: "Tren Superior",
  },
  {
    name: "Cruce de Poleas (Bajo)",
    muscleGroup: "Pectorales",
    bodyPart: "Tren Superior",
  },
  {
    name: "Fondos en Paralelas",
    muscleGroup: "Pectorales",
    bodyPart: "Tren Superior",
  },
  {
    name: "Pullover con Mancuerna",
    muscleGroup: "Pectorales",
    bodyPart: "Tren Superior",
  },
  { name: "Svend Press", muscleGroup: "Pectorales", bodyPart: "Tren Superior" },
  {
    name: "Landmine Press",
    muscleGroup: "Pectorales",
    bodyPart: "Tren Superior",
  },

  // Espalda
  {
    name: "Dominadas (Pull-ups)",
    muscleGroup: "Espalda",
    bodyPart: "Tren Superior",
  },
  {
    name: "Dominadas Supinas (Chin-ups)",
    muscleGroup: "Espalda",
    bodyPart: "Tren Superior",
  },
  {
    name: "Jalón al Pecho (Agarre Prono)",
    muscleGroup: "Espalda",
    bodyPart: "Tren Superior",
  },
  {
    name: "Jalón al Pecho (Agarre Supino)",
    muscleGroup: "Espalda",
    bodyPart: "Tren Superior",
  },
  {
    name: "Jalón al Pecho (Agarre Neutro)",
    muscleGroup: "Espalda",
    bodyPart: "Tren Superior",
  },
  {
    name: "Remo con Barra (Pendlay)",
    muscleGroup: "Espalda",
    bodyPart: "Tren Superior",
  },
  {
    name: "Remo con Mancuerna (Unilateral)",
    muscleGroup: "Espalda",
    bodyPart: "Tren Superior",
  },
  {
    name: "Remo en Polea Baja (Girona)",
    muscleGroup: "Espalda",
    bodyPart: "Tren Superior",
  },
  {
    name: "Remo T (T-Bar-Row)",
    muscleGroup: "Espalda",
    bodyPart: "Tren Superior",
  },
  {
    name: "Remo en Máquina",
    muscleGroup: "Espalda",
    bodyPart: "Tren Superior",
  },
  {
    name: "Peso Muerto Convencional",
    muscleGroup: "Espalda",
    bodyPart: "Tren Superior",
  },
  { name: "Rack Pull", muscleGroup: "Espalda", bodyPart: "Tren Superior" },
  {
    name: "Hiperextensiones",
    muscleGroup: "Espalda",
    bodyPart: "Tren Superior",
  },
  {
    name: "Pull-over en Polea Alta",
    muscleGroup: "Espalda",
    bodyPart: "Tren Superior",
  },
  {
    name: "Shrugs (Encogimientos) con Barra",
    muscleGroup: "Espalda",
    bodyPart: "Tren Superior",
  },
  {
    name: "Shrugs (Encogimientos) con Mancuernas",
    muscleGroup: "Espalda",
    bodyPart: "Tren Superior",
  },

  // Hombros
  {
    name: "Press Militar con Barra",
    muscleGroup: "Hombros",
    bodyPart: "Tren Superior",
  },
  {
    name: "Press Militar con Mancuernas",
    muscleGroup: "Hombros",
    bodyPart: "Tren Superior",
  },
  { name: "Press Arnold", muscleGroup: "Hombros", bodyPart: "Tren Superior" },
  {
    name: "Elevaciones Laterales con Mancuernas",
    muscleGroup: "Hombros",
    bodyPart: "Tren Superior",
  },
  {
    name: "Elevaciones Laterales en Polea",
    muscleGroup: "Hombros",
    bodyPart: "Tren Superior",
  },
  {
    name: "Elevaciones Frontales con Mancuernas",
    muscleGroup: "Hombros",
    bodyPart: "Tren Superior",
  },
  {
    name: "Elevaciones Frontales con Disco",
    muscleGroup: "Hombros",
    bodyPart: "Tren Superior",
  },
  {
    name: "Pájaros (Elevaciones Posteriores)",
    muscleGroup: "Hombros",
    bodyPart: "Tren Superior",
  },
  { name: "Face Pull", muscleGroup: "Hombros", bodyPart: "Tren Superior" },
  {
    name: "Remo al Mentón (Upright Row)",
    muscleGroup: "Hombros",
    bodyPart: "Tren Superior",
  },
  {
    name: "Vuelos Invertidos en Máquina",
    muscleGroup: "Hombros",
    bodyPart: "Tren Superior",
  },

  // Bíceps
  {
    name: "Curl con Barra (De Pie)",
    muscleGroup: "Bíceps",
    bodyPart: "Tren Superior",
  },
  {
    name: "Curl con Barra Z",
    muscleGroup: "Bíceps",
    bodyPart: "Tren Superior",
  },
  { name: "Curl Martillo", muscleGroup: "Bíceps", bodyPart: "Tren Superior" },
  {
    name: "Curl Predicador (Banco Scott)",
    muscleGroup: "Bíceps",
    bodyPart: "Tren Superior",
  },
  {
    name: "Curl Concentrado",
    muscleGroup: "Bíceps",
    bodyPart: "Tren Superior",
  },
  {
    name: "Curl Inclinado con Mancuernas",
    muscleGroup: "Bíceps",
    bodyPart: "Tren Superior",
  },
  {
    name: "Curl Araña (Spider Curl)",
    muscleGroup: "Bíceps",
    bodyPart: "Tren Superior",
  },
  {
    name: "Curl de Bíceps en Polea Baja",
    muscleGroup: "Bíceps",
    bodyPart: "Tren Superior",
  },
  { name: "Curl 21", muscleGroup: "Bíceps", bodyPart: "Tren Superior" },

  // Tríceps
  {
    name: "Press Francés (Skullcrushers)",
    muscleGroup: "Tríceps",
    bodyPart: "Tren Superior",
  },
  {
    name: "Press de Banca Agarre Cerrado",
    muscleGroup: "Tríceps",
    bodyPart: "Tren Superior",
  },
  {
    name: "Extensiones de Tríceps en Polea (Cuerda)",
    muscleGroup: "Tríceps",
    bodyPart: "Tren Superior",
  },
  {
    name: "Extensiones de Tríceps en Polea (Barra)",
    muscleGroup: "Tríceps",
    bodyPart: "Tren Superior",
  },
  {
    name: "Fondos entre Bancos (Dips)",
    muscleGroup: "Tríceps",
    bodyPart: "Tren Superior",
  },
  {
    name: "Patada de Tríceps",
    muscleGroup: "Tríceps",
    bodyPart: "Tren Superior",
  },
  {
    name: "Copa a Dos Manos",
    muscleGroup: "Tríceps",
    bodyPart: "Tren Superior",
  },
  {
    name: "Extensiones sobre la cabeza (Cable)",
    muscleGroup: "Tríceps",
    bodyPart: "Tren Superior",
  },

  // Abdominales / Core
  {
    name: "Crunch Abdominal",
    muscleGroup: "Abdominales",
    bodyPart: "Tren Superior",
  },
  {
    name: "Plancha (Plank)",
    muscleGroup: "Abdominales",
    bodyPart: "Tren Superior",
  },
  {
    name: "Plancha Lateral",
    muscleGroup: "Abdominales",
    bodyPart: "Tren Superior",
  },
  {
    name: "Elevación de Piernas (Colgado)",
    muscleGroup: "Abdominales",
    bodyPart: "Tren Superior",
  },
  {
    name: "Rueda Abdominal (Ab Wheel)",
    muscleGroup: "Abdominales",
    bodyPart: "Tren Superior",
  },
  {
    name: "Russian Twist",
    muscleGroup: "Abdominales",
    bodyPart: "Tren Superior",
  },
  {
    name: "Mountain Climbers",
    muscleGroup: "Abdominales",
    bodyPart: "Tren Superior",
  },
  {
    name: "Leñador (Woodchoppers)",
    muscleGroup: "Abdominales",
    bodyPart: "Tren Superior",
  },
  {
    name: "Vacuum Abdominal",
    muscleGroup: "Abdominales",
    bodyPart: "Tren Superior",
  },

  // --- TREN INFERIOR (EXISTING + NEW) ---
  // Cuádriceps
  {
    name: "Sentadilla (Squat)",
    muscleGroup: "Cuádriceps",
    bodyPart: "Tren Inferior",
  },
  {
    name: "Sentadilla Frontal",
    muscleGroup: "Cuádriceps",
    bodyPart: "Tren Inferior",
  },
  {
    name: "Sentadilla Goblet",
    muscleGroup: "Cuádriceps",
    bodyPart: "Tren Inferior",
  },
  {
    name: "Sentadilla Hack",
    muscleGroup: "Cuádriceps",
    bodyPart: "Tren Inferior",
  },
  {
    name: "Sentadilla Sissy",
    muscleGroup: "Cuádriceps",
    bodyPart: "Tren Inferior",
  },
  {
    name: "Prensa de Piernas (Leg Press)",
    muscleGroup: "Cuádriceps",
    bodyPart: "Tren Inferior",
  },
  {
    name: "Zancadas (Lunges)",
    muscleGroup: "Cuádriceps",
    bodyPart: "Tren Inferior",
  },
  {
    name: "Zancadas Inversas",
    muscleGroup: "Cuádriceps",
    bodyPart: "Tren Inferior",
  },
  {
    name: "Extensión de Cuádriceps",
    muscleGroup: "Cuádriceps",
    bodyPart: "Tren Inferior",
  },
  {
    name: "Sentadilla Búlgara",
    muscleGroup: "Cuádriceps",
    bodyPart: "Tren Inferior",
  },
  {
    name: "Step-ups (Subida al Cajón)",
    muscleGroup: "Cuádriceps",
    bodyPart: "Tren Inferior",
  },

  // Isquiotibiales (Femoral)
  {
    name: "Peso Muerto Rumano (Barra)",
    muscleGroup: "Isquiotibiales",
    bodyPart: "Tren Inferior",
  },
  {
    name: "Peso Muerto Rumano (Mancuernas)",
    muscleGroup: "Isquiotibiales",
    bodyPart: "Tren Inferior",
  },
  {
    name: "Curl Femoral Tumbado",
    muscleGroup: "Isquiotibiales",
    bodyPart: "Tren Inferior",
  },
  {
    name: "Curl Femoral Sentado",
    muscleGroup: "Isquiotibiales",
    bodyPart: "Tren Inferior",
  },
  {
    name: "Buenos Días (Good Mornings)",
    muscleGroup: "Isquiotibiales",
    bodyPart: "Tren Inferior",
  },
  {
    name: "Peso Muerto Piernas Rígidas",
    muscleGroup: "Isquiotibiales",
    bodyPart: "Tren Inferior",
  },
  {
    name: "Curl Nórdico",
    muscleGroup: "Isquiotibiales",
    bodyPart: "Tren Inferior",
  },

  // Glúteos
  {
    name: "Hip Thrust (Barra)",
    muscleGroup: "Glúteos",
    bodyPart: "Tren Inferior",
  },
  {
    name: "Hip Thrust (Máquina)",
    muscleGroup: "Glúteos",
    bodyPart: "Tren Inferior",
  },
  {
    name: "Puente de Glúteo (Glute Bridge)",
    muscleGroup: "Glúteos",
    bodyPart: "Tren Inferior",
  },
  {
    name: "Patada de Glúteo en Polea",
    muscleGroup: "Glúteos",
    bodyPart: "Tren Inferior",
  },
  {
    name: "Abducción de Cadera (Máquina)",
    muscleGroup: "Glúteos",
    bodyPart: "Tren Inferior",
  },
  { name: "Frog Pumps", muscleGroup: "Glúteos", bodyPart: "Tren Inferior" },
  {
    name: "Monster Walk (Banda Elástica)",
    muscleGroup: "Glúteos",
    bodyPart: "Tren Inferior",
  },
  {
    name: "Patada de Glúteo (Máquina)",
    muscleGroup: "Glúteos",
    bodyPart: "Tren Inferior",
  },

  // Gemelos
  {
    name: "Elevación de Talones de Pie",
    muscleGroup: "Gemelos",
    bodyPart: "Tren Inferior",
  },
  {
    name: "Elevación de Talones Sentado",
    muscleGroup: "Gemelos",
    bodyPart: "Tren Inferior",
  },
  {
    name: "Elevación de Talones en Prensa",
    muscleGroup: "Gemelos",
    bodyPart: "Tren Inferior",
  },
  {
    name: "Saltar la Cuerda",
    muscleGroup: "Gemelos",
    bodyPart: "Tren Inferior",
  },

  // Cardio / Full Body
  { name: "Burpees", muscleGroup: "Cardio", bodyPart: "Tren Inferior" }, // Categorized loosely
  {
    name: "Kettlebell Swing",
    muscleGroup: "Isquiotibiales",
    bodyPart: "Tren Inferior",
  },
  {
    name: "Remo (Ergómetro)",
    muscleGroup: "Cardio",
    bodyPart: "Tren Superior",
  },
  { name: "Elíptica", muscleGroup: "Cardio", bodyPart: "Tren Inferior" },
];

async function main() {
  console.log("🌱 Seeding Extended Exercises...");

  // 1. Get existing exercise names
  const existing = await prisma.exercise.findMany({
    select: { name: true },
  });
  const existingNames = new Set(existing.map((e) => e.name));

  // 2. Filter new exercises
  const newExercises = exercises.filter((ex) => !existingNames.has(ex.name));

  if (newExercises.length === 0) {
    console.log("All exercises already exist. No new insertions.");
    return;
  }

  // 3. Insert new exercises
  const created = await prisma.exercise.createMany({
    data: newExercises,
  });

  console.log(`✅ Added ${created.count} NEW exercises.`);
}

main()
  .catch((e) => {
    console.error(e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
