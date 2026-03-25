<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class EscalaSalarial extends Model
{
    protected $table = 'escala_salarial';
    protected $fillable = [
        'anio', 'seccion', 'categoria', 'perfil',
        'nivel', 'puesto', 'modalidad', 'valor',
        'junior', 'senior', 'master',
    ];
}