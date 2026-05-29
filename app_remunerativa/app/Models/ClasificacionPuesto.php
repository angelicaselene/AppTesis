<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class ClasificacionPuesto extends Model
{
    protected $table = 'clasificacion_puestos';

    protected $fillable = [
        'categoria',
        'perfil',
        'nivel',
        'puesto',
    ];
}
