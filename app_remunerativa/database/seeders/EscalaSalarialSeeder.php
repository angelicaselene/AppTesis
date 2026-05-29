<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\EscalaSalarial;
use PhpOffice\PhpSpreadsheet\IOFactory;

class EscalaSalarialSeeder extends Seeder
{
    public function run(): void
    {
        $path = storage_path('app') . DIRECTORY_SEPARATOR . '02 ESCALA SALARIAL USS 2025 - VACIO (1).xlsx';
        $spreadsheet = \PhpOffice\PhpSpreadsheet\IOFactory::load($path);
        $ws = $spreadsheet->getSheetByName('ESCALA');
        $rows = $ws->toArray();

        $anio = '2025';
        $seccion = 'ACADÉMICOS';
        $insertados = 0;

        foreach ($rows as $i => $row) {
            if ($i < 3) continue;

            // Detectar cambio de sección
            if (!empty($row[1]) && str_contains(strtoupper($row[1]), 'ESCALA DE REMUNERACIONES')) {
                if (str_contains(strtoupper($row[1]), 'ADMINISTRATIVOS')) {
                    $seccion = 'ADMINISTRATIVOS';
                } else {
                    $seccion = 'ACADÉMICOS';
                }
                continue;
            }

            // Saltar encabezados
            if (!empty($row[1]) && strtoupper(trim($row[1])) === 'CATEGORIA') continue;

            $puesto = trim($row[4] ?? '');
            if (empty($puesto)) continue;

            EscalaSalarial::create([
                'anio'      => $anio,
                'seccion'   => $seccion,
                'categoria' => trim($row[1] ?? ''),
                'perfil'    => trim($row[2] ?? ''),
                'nivel'     => trim($row[3] ?? ''),
                'puesto'    => $puesto,
                'modalidad' => trim($row[5] ?? ''),
                'valor'     => is_numeric($row[6]) ? $row[6] : null,
                'junior'    => is_numeric($row[7]) ? $row[7] : null,
                'senior'    => is_numeric($row[8]) ? $row[8] : null,
                'master'    => is_numeric($row[9]) ? $row[9] : null,
            ]);
            $insertados++;
        }

        echo "Insertados: $insertados registros de escala salarial\n";
    }
}