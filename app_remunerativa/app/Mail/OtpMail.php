<?php

namespace App\Mail;

use Illuminate\Bus\Queueable;
use Illuminate\Mail\Mailable;
use Illuminate\Queue\SerializesModels;

class OtpMail extends Mailable
{
    use Queueable, SerializesModels;

    public string $otp;
    public string $nombres;

    public function __construct(string $otp, string $nombres)
    {
        $this->otp = $otp;
        $this->nombres = $nombres;
    }

    public function build(): self
    {
        return $this
            ->subject('Código de recuperación - USS')
            ->html("
                <div style='font-family: Arial, sans-serif; max-width: 500px; margin: auto;'>
                    <div style='background-color: #6B2D8B; padding: 20px; border-radius: 8px 8px 0 0;'>
                        <h2 style='color: white; margin: 0;'>Recuperación de Contraseña</h2>
                        <p style='color: #e0e0e0; margin: 4px 0 0;'>Sistema de Gestión Remunerativa USS</p>
                    </div>
                    <div style='background: #f9f9f9; padding: 24px; border-radius: 0 0 8px 8px;'>
                        <p>Hola <strong>{$this->nombres}</strong>,</p>
                        <p>Tu código de verificación es:</p>
                        <div style='background: #6B2D8B; color: white; font-size: 32px; font-weight: bold;
                                    letter-spacing: 10px; text-align: center; padding: 20px;
                                    border-radius: 8px; margin: 20px 0;'>
                            {$this->otp}
                        </div>
                        <p style='color: #666;'>Este código expira en <strong>10 minutos</strong>.</p>
                        <p style='color: #666;'>Si no solicitaste esto, ignora este correo.</p>
                    </div>
                </div>
            ");
    }
}