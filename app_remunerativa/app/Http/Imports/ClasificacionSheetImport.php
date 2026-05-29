<?php

namespace App\Imports;

use App\Models\ClasificacionPuesto;
use Maatwebsite\Excel\Concerns\ToCollection;
use Maatwebsite\Excel\Concerns\WithStartRow;
use Illuminate\Support\Collection;

class ClasificacionSheetImport implements ToCollection, WithStartRow
{
    public function startRow(): int
    {
        return 3;
    }

    public function collection(Collection $rows)
    {
        $currentCategoria = '';
        $currentPerfil = '';

        foreach ($rows as $row) {
            $categoria = isset($row[2]) ? trim($row[2]) : null;
            $perfil    = isset($row[3]) ? trim($row[3]) : null;
            $nivel     = isset($row[4]) ? trim($row[4]) : null;
            $puesto    = isset($row[5]) ? trim($row[5]) : null;

            if (!empty($categoria)) $currentCategoria = $categoria;
            if (!empty($perfil))    $currentPerfil    = $perfil;

            if (empty($nivel) || empty($puesto) || empty($currentCategoria)) continue;

            ClasificacionPuesto::firstOrCreate(
                ['puesto' => $puesto],
                [
                    'categoria' => $currentCategoria,
                    'perfil'    => $currentPerfil,
                    'nivel'     => $nivel,
                ]
            );
        }
    }
}