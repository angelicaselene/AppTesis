<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    public function up(): void {
        Schema::create('historial_salarial', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained('users')->onDelete('cascade');
            $table->string('cargo')->nullable();
            $table->decimal('remuneracion', 10, 2)->nullable();
            $table->date('fecha');
            $table->timestamps();
        });
    }

    public function down(): void {
        Schema::dropIfExists('historial_salarial');
    }
};