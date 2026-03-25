<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class HistorialSalarial extends Model
{
    protected $table = 'historial_salarial';
    protected $fillable = ['user_id', 'cargo', 'remuneracion', 'fecha'];

    public function user()
    {
        return $this->belongsTo(User::class);
    }
}