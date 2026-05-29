<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;
use PhpOffice\PhpSpreadsheet\IOFactory;

class ValuacionPuestosSeeder extends Seeder
{
    public function run(): void
    {
        $path = storage_path('app') . DIRECTORY_SEPARATOR . '02 ESCALA SALARIAL USS 2025 - VACIO (1).xlsx';
        $spreadsheet = IOFactory::load($path);
        $ws = $spreadsheet->getSheetByName('Valuacion');
        $rows = $ws->toArray();

        $categoriaActual = null;
        $insertados = 0;

        foreach ($rows as $i => $row) {
            if ($i < 3) continue; // saltar encabezados

            $puesto = trim($row[3] ?? '');
            if (empty($puesto)) continue;

            if (!empty($row[2])) {
                $categoriaActual = trim($row[2]);
            }

            DB::table('valuacion_puestos')->insertOrIgnore([
                'categoria'                   => $categoriaActual,
                'puesto'                      => strtoupper($puesto),
                'formacion_profesional'       => (int)($row[4] ?? 0),
                'investigacion'               => (int)($row[5] ?? 0),
                'experiencia'                 => (int)($row[6] ?? 0),
                'excelencia_servicio'         => (int)($row[7] ?? 0),
                'capacidad_resolutiva'        => (int)($row[8] ?? 0),
                'emprendimiento'              => (int)($row[9] ?? 0),
                'innovacion'                  => (int)($row[10] ?? 0),
                'competencia_digital'         => (int)($row[11] ?? 0),
                'mental'                      => (int)($row[12] ?? 0),
                'emocional'                   => (int)($row[13] ?? 0),
                'fisico'                      => (int)($row[14] ?? 0),
                'cumplimiento_metas'          => (int)($row[15] ?? 0),
                'responsabilidades_financieras' => (int)($row[16] ?? 0),
                'prestacion_servicios'        => (int)($row[17] ?? 0),
                'confidencialidad'            => (int)($row[18] ?? 0),
                'manejo_materiales'           => (int)($row[19] ?? 0),
                'manejo_personas'             => (int)($row[20] ?? 0),
                'riesgo_ambiental'            => (int)($row[21] ?? 0),
                'riesgo_psicologico'          => (int)($row[22] ?? 0),
            ]);
            $insertados++;
        }

        echo "Insertados: $insertados puestos\n";
    }
}