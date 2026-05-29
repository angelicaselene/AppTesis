<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class HistorialRemuneracion extends Model
{
    protected $table = 'historial_remuneracion';
    protected $fillable = ['dni', 'cargo', 'anio', 'mes', 'remuneracion'];
}