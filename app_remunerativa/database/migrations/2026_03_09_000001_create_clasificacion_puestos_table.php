<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('clasificacion_puestos', function (Blueprint $table) {
            $table->id();
            $table->string('categoria');
            $table->string('perfil');
            $table->string('nivel', 10);
            $table->string('puesto');
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('clasificacion_puestos');
    }
};
