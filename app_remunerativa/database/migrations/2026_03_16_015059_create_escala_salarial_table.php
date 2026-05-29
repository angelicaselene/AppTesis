<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    public function up(): void {
        Schema::create('escala_salarial', function (Blueprint $table) {
            $table->id();
            $table->string('anio');
            $table->string('seccion'); // ACADÉMICOS, ADMINISTRATIVOS
            $table->string('categoria')->nullable();
            $table->string('perfil')->nullable();
            $table->string('nivel')->nullable();
            $table->string('puesto');
            $table->string('modalidad')->nullable();
            $table->decimal('valor', 10, 2)->nullable();
            $table->decimal('junior', 10, 2)->nullable();
            $table->decimal('senior', 10, 2)->nullable();
            $table->decimal('master', 10, 2)->nullable();
            $table->timestamps();
        });
    }

    public function down(): void {
        Schema::dropIfExists('escala_salarial');
    }
};