import { PrismaClient } from "@prisma/client";

const prisma = new PrismaClient();

const ORG_ID = "3d869695-7422-460b-8104-c4bcb641b30d";

const NUTRITION_DETAILS = `
<ul class="list-none space-y-2 text-xs text-gray-600">
    <li><strong>• Ensalada:</strong> Cualquier tipo puede ser ensaladas que aportan volumen. (A TU GUSTO)</li>
    <li><strong>• Proteína Reemplazo:</strong> Puede ser carne molida 1% de grasa, filete de carne y filete de pescado (Salmon, tilapia, pargo o atún). Recomendado mismas porciones puedes turnar diariamente tanto como semanal.</li>
    <li><strong>• Huevos:</strong> Pueden ser cocidos, a la plancha o revueltos sin aceite (ACEITE PAM 0KCALS)</li>
    <li><strong>• Café y aguas:</strong> Dejar las azucares y edulcorantes (STEVIA PUEDES CONSUMIR)</li>
    <li><strong>• Dieta:</strong> Establecida hasta terminar la definición.</li>
    <li><strong>• Agua:</strong> 8 vasos de agua diario – 4 A 3 Litros</li>
    <li><strong>• VitC:</strong> Despues de tu desayuno (OPCIONAL)</li>
    <li><strong>• Multivitaminas:</strong> Después de tu desayuno. (OPCIONAL)</li>
    <li><strong>• Cardio en ayunas:</strong> Diariamente LUNES-DOMINGO O 30min-10.000pasos/ 15.000 Pasos- El deporte que hagas.</li>
    <li><strong>• Vinagre de manzana:</strong> 1 cucharada después de tu cardio, antes de tu primera comida, mezclar con gotas de limón y un poco de agua para puedas tomarte. (OPCIONAL)</li>
    <li><strong>• Canela en polvo:</strong> Acompaña en los pancakes.</li>
    <li><strong>• MEDIA TARDE:</strong> Unir con la ultima comida si no tienes tiempo de hacerla o consumir mas comida en la cena mas proteina y mas cabohidrato.(EN TU CASO REDUCIR LAS PORCIONES)</li>
    <li><strong>• CEREALES POST ENTRENAMIENTO CON PROTEINA:</strong> Esta opcion 3 juega un papel fundamental en recuperacion de nutrientes post entreno y en este caso, puedes consumir cuando vengas a entrenar 6:00am.</li>
    <li><strong>• SALSAS 0 FITBA:</strong> Utilízalas con moderación.</li>
    <li><strong>• DIAS SIN ENTRENAMIENTO DE PESAS:</strong> Baja el consumo de carbohidratos.</li>
    <li><strong>• REEMPLAZO DE GRASAS SALUDABLES:</strong> NUECES, ALMENDRAS, CREMAS DE FRUTOS SECOS</li>
    <li><strong>• MOVILIDAD LOS DIAS QUE NO ENTRENES:</strong> SUBES A 15,000 PASOS O NADAR</li>
    <li><strong>• LOS DIAS QUE ENTRENES NATACION + /FUERZA:</strong> MOVILIDAD 10.000 PASOS Y SUBES 100gr DE CARBS CENA/MEDIA TARDE O UTILIZA LAS OPCIONES CENA FIT</li>
    <li><strong>• LOS DIAS DE CARBS BAJOS:</strong> PRIORIZA EL CONSUMO DE FRUTOS ROJOS</li>
    <li><strong>• CARBOHIDRATOS:</strong> PUEDES PRIORIZAR PAPAS CAMOTE, ZANAHORIA BLANCA, TODOS LOS ALIMENTOS INTEGRALES.</li>
    <li><strong>• CHEAT FIT:</strong> SUBIR CHO EN LOS DIAS DE ENTRENAMIENTO (CARDIO Y FUERZA) y luego si el plan como tal</li>
</ul>
`;

async function main() {
  console.log(`Updating Organization ${ORG_ID} with nutrition details...`);
  try {
    const updated = await prisma.organization.update({
      where: { id: ORG_ID },
      data: {
        nutritionDetails: NUTRITION_DETAILS,
      },
    });
    console.log("Successfully updated organization:", updated.name);
  } catch (error) {
    console.error("Error updating organization:", error);
    // If ID not found, maybe try finding by name or creating? Assuming ID is correct per user request.
    // If not found, list all orgs
    const orgs = await prisma.organization.findMany();
    console.log(
      "Available Organizations:",
      orgs.map((o) => ({ id: o.id, name: o.name }))
    );
  } finally {
    await prisma.$disconnect();
  }
}

main();
