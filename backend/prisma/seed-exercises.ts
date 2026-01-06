import { PrismaClient } from "@prisma/client";

const prisma = new PrismaClient();

const exercises = [
  // TREN SUPERIOR - PECHO
  {
    name: "Press de Banca con Barra",
    muscleGroup: "Pecho",
    bodyPart: "Tren Superior",
  },
  {
    name: "Press de Banca con Mancuernas",
    muscleGroup: "Pecho",
    bodyPart: "Tren Superior",
  },
  {
    name: "Aperturas con Mancuernas",
    muscleGroup: "Pecho",
    bodyPart: "Tren Superior",
  },
  {
    name: "Press Inclinado con Barra",
    muscleGroup: "Pecho",
    bodyPart: "Tren Superior",
  },
  {
    name: "Press Inclinado con Mancuernas",
    muscleGroup: "Pecho",
    bodyPart: "Tren Superior",
  },
  {
    name: "Press Declinado con Barra",
    muscleGroup: "Pecho",
    bodyPart: "Tren Superior",
  },
  {
    name: "Cruce de Poleas (Desde Arriba)",
    muscleGroup: "Pecho",
    bodyPart: "Tren Superior",
  },
  {
    name: "Cruce de Poleas (Desde Abajo)",
    muscleGroup: "Pecho",
    bodyPart: "Tren Superior",
  },
  {
    name: "Pec Deck (Contractora)",
    muscleGroup: "Pecho",
    bodyPart: "Tren Superior",
  },
  {
    name: "Flexiones de Brazos (Lagartijas)",
    muscleGroup: "Pecho",
    bodyPart: "Tren Superior",
  },
  {
    name: "Dips (Fondos) para Pecho",
    muscleGroup: "Pecho",
    bodyPart: "Tren Superior",
  },
  {
    name: "Press de Pecho en Máquina Hammer",
    muscleGroup: "Pecho",
    bodyPart: "Tren Superior",
  },
  {
    name: "Press de Pecho en Máquina Smith",
    muscleGroup: "Pecho",
    bodyPart: "Tren Superior",
  },
  {
    name: "Aperturas en Polea",
    muscleGroup: "Pecho",
    bodyPart: "Tren Superior",
  },
  {
    name: "Pull-over con Mancuerna",
    muscleGroup: "Pecho",
    bodyPart: "Tren Superior",
  },

  // TREN SUPERIOR - ESPALDA
  {
    name: "Dominadas (Pull-ups)",
    muscleGroup: "Espalda",
    bodyPart: "Tren Superior",
  },
  {
    name: "Jalón al Pecho (Polea Alta)",
    muscleGroup: "Espalda",
    bodyPart: "Tren Superior",
  },
  { name: "Remo con Barra", muscleGroup: "Espalda", bodyPart: "Tren Superior" },
  {
    name: "Remo con Mancuerna a una Mano",
    muscleGroup: "Espalda",
    bodyPart: "Tren Superior",
  },
  {
    name: "Remo en Polea Baja (Gironda)",
    muscleGroup: "Espalda",
    bodyPart: "Tren Superior",
  },
  { name: "Remo T", muscleGroup: "Espalda", bodyPart: "Tren Superior" },
  {
    name: "Peso Muerto Convencional",
    muscleGroup: "Espalda",
    bodyPart: "Tren Superior",
  },
  {
    name: "Pull-over en Polea Alta (Brazos Rectos)",
    muscleGroup: "Espalda",
    bodyPart: "Tren Superior",
  },
  {
    name: "Jalón al Pecho con Agarre Cerrado",
    muscleGroup: "Espalda",
    bodyPart: "Tren Superior",
  },
  {
    name: "Remo en Máquina Hammer",
    muscleGroup: "Espalda",
    bodyPart: "Tren Superior",
  },
  {
    name: "Hiperextensiones Lumbar",
    muscleGroup: "Espalda",
    bodyPart: "Tren Superior",
  },
  { name: "Remo Pendlay", muscleGroup: "Espalda", bodyPart: "Tren Superior" },
  {
    name: "Dominadas Asistidas",
    muscleGroup: "Espalda",
    bodyPart: "Tren Superior",
  },
  {
    name: "Remo con Soporte al Pecho",
    muscleGroup: "Espalda",
    bodyPart: "Tren Superior",
  },
  {
    name: "Buenos Días (Good Mornings)",
    muscleGroup: "Espalda",
    bodyPart: "Tren Superior",
  },

  // TREN SUPERIOR - HOMBROS
  {
    name: "Press Militar con Barra",
    muscleGroup: "Hombros",
    bodyPart: "Tren Superior",
  },
  {
    name: "Press de Hombro con Mancuernas",
    muscleGroup: "Hombros",
    bodyPart: "Tren Superior",
  },
  {
    name: "Elevaciones Laterales con Mancuernas",
    muscleGroup: "Hombros",
    bodyPart: "Tren Superior",
  },
  {
    name: "Elevaciones Frontales con Mancuernas",
    muscleGroup: "Hombros",
    bodyPart: "Tren Superior",
  },
  {
    name: "Pájaros (Vuelos Posteriores)",
    muscleGroup: "Hombros",
    bodyPart: "Tren Superior",
  },
  { name: "Press Arnold", muscleGroup: "Hombros", bodyPart: "Tren Superior" },
  {
    name: "Remo al Mentón con Barra",
    muscleGroup: "Hombros",
    bodyPart: "Tren Superior",
  },
  {
    name: "Face Pull (Polea al Rostro)",
    muscleGroup: "Hombros",
    bodyPart: "Tren Superior",
  },
  {
    name: "Press Militar en Máquina Smith",
    muscleGroup: "Hombros",
    bodyPart: "Tren Superior",
  },
  {
    name: "Elevaciones Laterales en Polea",
    muscleGroup: "Hombros",
    bodyPart: "Tren Superior",
  },
  {
    name: "Encogimientos de Hombros con Mancuernas",
    muscleGroup: "Hombros",
    bodyPart: "Tren Superior",
  },
  {
    name: "Press de Hombro en Polea",
    muscleGroup: "Hombros",
    bodyPart: "Tren Superior",
  },
  {
    name: "Vuelos Laterales en Máquina",
    muscleGroup: "Hombros",
    bodyPart: "Tren Superior",
  },
  {
    name: "Press de Hombro en Máquina Convergente",
    muscleGroup: "Hombros",
    bodyPart: "Tren Superior",
  },
  {
    name: "Elevaciones Frontales con Disco",
    muscleGroup: "Hombros",
    bodyPart: "Tren Superior",
  },

  // TREN SUPERIOR - BRAZOS (BICEPS)
  {
    name: "Curl de Biceps con Barra",
    muscleGroup: "Biceps",
    bodyPart: "Tren Superior",
  },
  {
    name: "Curl de Biceps con Mancuernas",
    muscleGroup: "Biceps",
    bodyPart: "Tren Superior",
  },
  {
    name: "Curl de Biceps Martillo",
    muscleGroup: "Biceps",
    bodyPart: "Tren Superior",
  },
  {
    name: "Curl Scott (Predicador)",
    muscleGroup: "Biceps",
    bodyPart: "Tren Superior",
  },
  {
    name: "Curl de Biceps Concentrado",
    muscleGroup: "Biceps",
    bodyPart: "Tren Superior",
  },
  {
    name: "Curl de Biceps en Polea Baja",
    muscleGroup: "Biceps",
    bodyPart: "Tren Superior",
  },
  {
    name: "Curl de Biceps con Barra Z",
    muscleGroup: "Biceps",
    bodyPart: "Tren Superior",
  },
  {
    name: "Curl Inclinado con Mancuernas",
    muscleGroup: "Biceps",
    bodyPart: "Tren Superior",
  },
  { name: "Curl Araña", muscleGroup: "Biceps", bodyPart: "Tren Superior" },
  {
    name: "Curl de Biceps en Cruz (Polea Alta)",
    muscleGroup: "Biceps",
    bodyPart: "Tren Superior",
  },
  {
    name: "Curl de Biceps con Agarre Inverso",
    muscleGroup: "Biceps",
    bodyPart: "Tren Superior",
  },
  { name: "21 (Veintiunos)", muscleGroup: "Biceps", bodyPart: "Tren Superior" },
  {
    name: "Curl de Biceps en Máquina",
    muscleGroup: "Biceps",
    bodyPart: "Tren Superior",
  },
  {
    name: "Curl de Biceps tipo Zottman",
    muscleGroup: "Biceps",
    bodyPart: "Tren Superior",
  },
  { name: "Drag Curl", muscleGroup: "Biceps", bodyPart: "Tren Superior" },

  // TREN SUPERIOR - BRAZOS (TRICEPS)
  {
    name: "Press Francés con Barra Z",
    muscleGroup: "Triceps",
    bodyPart: "Tren Superior",
  },
  {
    name: "Extensiones de Triceps en Polea Alta (Cuerda)",
    muscleGroup: "Triceps",
    bodyPart: "Tren Superior",
  },
  {
    name: "Extensiones de Triceps en Polea Alta (Barra)",
    muscleGroup: "Triceps",
    bodyPart: "Tren Superior",
  },
  {
    name: "Dips (Fondos) entre Bancos",
    muscleGroup: "Triceps",
    bodyPart: "Tren Superior",
  },
  {
    name: "Press de Banca con Agarre Cerrado",
    muscleGroup: "Triceps",
    bodyPart: "Tren Superior",
  },
  {
    name: "Copa de Triceps (Extensión sobre la cabeza)",
    muscleGroup: "Triceps",
    bodyPart: "Tren Superior",
  },
  {
    name: "Patada de Triceps con Mancuerna",
    muscleGroup: "Triceps",
    bodyPart: "Tren Superior",
  },
  {
    name: "Extensiones de Triceps a una mano",
    muscleGroup: "Triceps",
    bodyPart: "Tren Superior",
  },
  {
    name: "Skullcrushers con Mancuernas",
    muscleGroup: "Triceps",
    bodyPart: "Tren Superior",
  },
  {
    name: "Dips (Fondos) en Paralelas",
    muscleGroup: "Triceps",
    bodyPart: "Tren Superior",
  },
  {
    name: "Extensión de Triceps en Polea por encima de la cabeza",
    muscleGroup: "Triceps",
    bodyPart: "Tren Superior",
  },
  {
    name: "Extensiones de Triceps en Máquina",
    muscleGroup: "Triceps",
    bodyPart: "Tren Superior",
  },
  {
    name: "Flexiones con Agarre Diamante",
    muscleGroup: "Triceps",
    bodyPart: "Tren Superior",
  },
  {
    name: "Push Down con Agarre Inverso",
    muscleGroup: "Triceps",
    bodyPart: "Tren Superior",
  },
  {
    name: "Extensión de Triceps con TRX",
    muscleGroup: "Triceps",
    bodyPart: "Tren Superior",
  },

  // TREN INFERIOR - PIERNA (CUADRICEPS)
  {
    name: "Sentadilla Libre con Barra (Atrás)",
    muscleGroup: "Pierna",
    bodyPart: "Tren Inferior",
  },
  {
    name: "Sentadilla Frontal",
    muscleGroup: "Pierna",
    bodyPart: "Tren Inferior",
  },
  {
    name: "Prensa de Piernas (Leg Press)",
    muscleGroup: "Pierna",
    bodyPart: "Tren Inferior",
  },
  {
    name: "Extensiones de Pierna en Máquina",
    muscleGroup: "Pierna",
    bodyPart: "Tren Inferior",
  },
  {
    name: "Zancadas (Lunges) con Barra",
    muscleGroup: "Pierna",
    bodyPart: "Tren Inferior",
  },
  {
    name: "Zancadas con Mancuernas",
    muscleGroup: "Pierna",
    bodyPart: "Tren Inferior",
  },
  {
    name: "Sentadilla Búlgara",
    muscleGroup: "Pierna",
    bodyPart: "Tren Inferior",
  },
  { name: "Sentadilla Hack", muscleGroup: "Pierna", bodyPart: "Tren Inferior" },
  {
    name: "Sentadilla Goblet",
    muscleGroup: "Pierna",
    bodyPart: "Tren Inferior",
  },
  {
    name: "Sentadilla en Máquina Smith",
    muscleGroup: "Pierna",
    bodyPart: "Tren Inferior",
  },
  {
    name: "Step Ups con Mancuernas",
    muscleGroup: "Pierna",
    bodyPart: "Tren Inferior",
  },
  { name: "Sissy Squat", muscleGroup: "Pierna", bodyPart: "Tren Inferior" },
  {
    name: "Prensa de 45 Grados",
    muscleGroup: "Pierna",
    bodyPart: "Tren Inferior",
  },
  {
    name: "Sentadilla con Salto",
    muscleGroup: "Pierna",
    bodyPart: "Tren Inferior",
  },
  {
    name: "Zancadas Caminando",
    muscleGroup: "Pierna",
    bodyPart: "Tren Inferior",
  },

  // TREN INFERIOR - PIERNA (FEMORAL/ISQUIOS)
  {
    name: "Peso Muerto Rumano",
    muscleGroup: "Pierna",
    bodyPart: "Tren Inferior",
  },
  {
    name: "Curl de Pierna Acostado",
    muscleGroup: "Pierna",
    bodyPart: "Tren Inferior",
  },
  {
    name: "Curl de Pierna Sentado",
    muscleGroup: "Pierna",
    bodyPart: "Tren Inferior",
  },
  {
    name: "Buenos Días para Isquios",
    muscleGroup: "Pierna",
    bodyPart: "Tren Inferior",
  },
  {
    name: "Curl de Pierna de Pie",
    muscleGroup: "Pierna",
    bodyPart: "Tren Inferior",
  },
  {
    name: "Peso Muerto con Piernas Semirrígidas",
    muscleGroup: "Pierna",
    bodyPart: "Tren Inferior",
  },
  { name: "Nordic Curls", muscleGroup: "Pierna", bodyPart: "Tren Inferior" },
  { name: "Glute-Ham Raise", muscleGroup: "Pierna", bodyPart: "Tren Inferior" },
  {
    name: "Extensiones de Cadera en Polea",
    muscleGroup: "Pierna",
    bodyPart: "Tren Inferior",
  },
  {
    name: "Peso Muerto Sumo",
    muscleGroup: "Pierna",
    bodyPart: "Tren Inferior",
  },
  {
    name: "Curl de Pierna con Fitball",
    muscleGroup: "Pierna",
    bodyPart: "Tren Inferior",
  },
  {
    name: "Puente de Glúteo a una Pierna",
    muscleGroup: "Pierna",
    bodyPart: "Tren Inferior",
  },
  {
    name: "Prensa Alta (Posición de Femoral)",
    muscleGroup: "Pierna",
    bodyPart: "Tren Inferior",
  },
  {
    name: "Zancadas Largas para Isquios",
    muscleGroup: "Pierna",
    bodyPart: "Tren Inferior",
  },
  {
    name: "Kettlebell Swing",
    muscleGroup: "Pierna",
    bodyPart: "Tren Inferior",
  },

  // TREN INFERIOR - GLÚTEOS
  {
    name: "Hip Thrust (Empuje de Cadera)",
    muscleGroup: "Glúteos",
    bodyPart: "Tren Inferior",
  },
  {
    name: "Glute Bridge con Peso",
    muscleGroup: "Glúteos",
    bodyPart: "Tren Inferior",
  },
  {
    name: "Patada de Glúteo en Polea",
    muscleGroup: "Glúteos",
    bodyPart: "Tren Inferior",
  },
  {
    name: "Aducción de Cadera en Polea",
    muscleGroup: "Glúteos",
    bodyPart: "Tren Inferior",
  },
  {
    name: "Abducción de Cadera en Máquina",
    muscleGroup: "Glúteos",
    bodyPart: "Tren Inferior",
  },
  {
    name: "Clamshells (Almejas)",
    muscleGroup: "Glúteos",
    bodyPart: "Tren Inferior",
  },
  {
    name: "Peso Muerto Single Leg",
    muscleGroup: "Glúteos",
    bodyPart: "Tren Inferior",
  },
  { name: "Frog Pumps", muscleGroup: "Glúteos", bodyPart: "Tren Inferior" },
  {
    name: "Monster Walk (con Banda)",
    muscleGroup: "Glúteos",
    bodyPart: "Tren Inferior",
  },
  {
    name: "Sentadilla Sumo con Mancuerna",
    muscleGroup: "Glúteos",
    bodyPart: "Tren Inferior",
  },
  {
    name: "Patada de Glúteo en Máquina",
    muscleGroup: "Glúteos",
    bodyPart: "Tren Inferior",
  },
  { name: "Fire Hydrants", muscleGroup: "Glúteos", bodyPart: "Tren Inferior" },
  {
    name: "Estocada Lateral",
    muscleGroup: "Glúteos",
    bodyPart: "Tren Inferior",
  },
  {
    name: "Caminar Lateral con Banda",
    muscleGroup: "Glúteos",
    bodyPart: "Tren Inferior",
  },
  {
    name: "Peso Muerto con Banda Elástica",
    muscleGroup: "Glúteos",
    bodyPart: "Tren Inferior",
  },

  // TREN INFERIOR - PANTORRILLAS
  {
    name: "Elevación de Talones de Pie en Máquina",
    muscleGroup: "Pantorrillas",
    bodyPart: "Tren Inferior",
  },
  {
    name: "Elevación de Talones Sentado en Máquina",
    muscleGroup: "Pantorrillas",
    bodyPart: "Tren Inferior",
  },
  {
    name: "Elevación de Talones en Prensa",
    muscleGroup: "Pantorrillas",
    bodyPart: "Tren Inferior",
  },
  {
    name: "Elevación de Talones tipo Burro",
    muscleGroup: "Pantorrillas",
    bodyPart: "Tren Inferior",
  },
  {
    name: "Caminata de Puntitas",
    muscleGroup: "Pantorrillas",
    bodyPart: "Tren Inferior",
  },
  {
    name: "Elevaciones de Talones con Mancuernas",
    muscleGroup: "Pantorrillas",
    bodyPart: "Tren Inferior",
  },
  {
    name: "Elevación de Talones en Máquina Smith",
    muscleGroup: "Pantorrillas",
    bodyPart: "Tren Inferior",
  },
  {
    name: "Elevaciones de Talones a una Pierna",
    muscleGroup: "Pantorrillas",
    bodyPart: "Tren Inferior",
  },
  {
    name: "Elevación de Talones en Step",
    muscleGroup: "Pantorrillas",
    bodyPart: "Tren Inferior",
  },
  {
    name: "Salto de Cuerda",
    muscleGroup: "Pantorrillas",
    bodyPart: "Tren Inferior",
  },
  {
    name: "Elevación de Talones en Polea Baja",
    muscleGroup: "Pantorrillas",
    bodyPart: "Tren Inferior",
  },
  {
    name: "Tibia Raise (Elevación Tibial)",
    muscleGroup: "Pantorrillas",
    bodyPart: "Tren Inferior",
  },
  {
    name: "Saltos Verticales",
    muscleGroup: "Pantorrillas",
    bodyPart: "Tren Inferior",
  },
  {
    name: "Skipping en el sitio",
    muscleGroup: "Pantorrillas",
    bodyPart: "Tren Inferior",
  },
  {
    name: "Zancadas explosivas",
    muscleGroup: "Pantorrillas",
    bodyPart: "Tren Inferior",
  },
];

async function main() {
  console.log("Seeding exercises...");
  for (const ex of exercises) {
    await prisma.exercise.create({
      data: ex,
    });
  }
  console.log("Seeding exercises completed successfully.");
}

main()
  .catch((e) => {
    console.error(e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
