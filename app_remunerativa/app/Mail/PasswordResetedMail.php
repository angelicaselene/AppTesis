<?php

namespace App\Mail;

use Illuminate\Bus\Queueable;
use Illuminate\Mail\Mailable;
use Illuminate\Queue\SerializesModels;

class PasswordResetedMail extends Mailable
{
    use Queueable, SerializesModels;

    public string $nombres;
    public string $dni;

    public function __construct(string $nombres, string $dni)
    {
        $this->nombres = $nombres;
        $this->dni     = $dni;
    }

    public function build(): self
    {
        return $this
            ->subject('Tu contraseña fue reseteada - USS')
            ->html("
                <div style='font-family: Arial, sans-serif; max-width: 500px; margin: auto;'>
                    <div style='background-color: #6B2D8B; padding: 20px; border-radius: 8px 8px 0 0;'>
                        <h2 style='color: white; margin: 0;'>Contraseña reseteada</h2>
                        <p style='color: #e0e0e0; margin: 4px 0 0;'>Sistema de Gestión Remunerativa USS</p>
                    </div>
                    <div style='background: #f9f9f9; padding: 24px; border-radius: 0 0 8px 8px;'>
                        <p>Hola <strong>{$this->nombres}</strong>,</p>
                        <p>El área de <strong>Recursos Humanos</strong> ha reseteado tu contraseña.</p>
                        <p>Tu nueva contraseña es tu número de DNI:</p>
                        <div style='background: #6B2D8B; color: white; font-size: 28px; font-weight: bold;
                                    letter-spacing: 8px; text-align: center; padding: 20px;
                                    border-radius: 8px; margin: 20px 0;'>
                            {$this->dni}
                        </div>
                        <p style='color: #666;'>Por seguridad, te recomendamos cambiar tu contraseña
                            después de iniciar sesión.</p>
                        <p style='color: #999; font-size: 12px;'>
                            Si no reconoces esta acción, comunícate con RR.HH.
                        </p>
                    </div>
                </div>
            ");
    }
}