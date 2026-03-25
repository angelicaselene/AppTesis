<?php

namespace App\Imports;

use Maatwebsite\Excel\Concerns\WithMultipleSheets;

class ClasificacionImport implements WithMultipleSheets
{
    public function sheets(): array
    {
        return [
            'Clasificacion' => new ClasificacionSheetImport(),
        ];
    }
}
