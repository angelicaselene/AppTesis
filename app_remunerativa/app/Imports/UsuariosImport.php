<?php

namespace App\Imports;

use Maatwebsite\Excel\Concerns\WithMultipleSheets;

class UsuariosImport implements WithMultipleSheets
{
    public function sheets(): array
    {
        return [
            'USS' => new UsuariosSheetImport(),
        ];
    }
}
