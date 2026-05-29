import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class PdfService {
  static Future<void> generarReporteAnalisis({
    required Map<String, dynamic> analisis,
    required Map<String, dynamic> rangos,
    required Map<String, dynamic> detalleEscala,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) => [
          // Título
          pw.Container(
            padding: const pw.EdgeInsets.all(16),
            decoration: pw.BoxDecoration(
              color: PdfColor.fromHex('6B2D8B'),
              borderRadius: pw.BorderRadius.circular(8),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'REPORTE DE ANÁLISIS SALARIAL',
                  style: pw.TextStyle(
                    color: PdfColors.white,
                    fontSize: 20,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.Text(
                  'Universidad Señor de Sipán - Gestión Remunerativa',
                  style: const pw.TextStyle(color: PdfColors.white, fontSize: 12),
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 20),

          // Sección 1: Costos
          _seccionTitulo('1. COSTOS MENSUALES'),
          pw.Row(
            children: [
              pw.Expanded(child: _card('Costo Actual', 'S/${_formatNum(rangos['costo_actual'])}')),
              pw.SizedBox(width: 12),
              pw.Expanded(child: _card('Costo Propuesto', 'S/${_formatNum(rangos['costo_propuesto'])}')),
              pw.SizedBox(width: 12),
              pw.Expanded(child: _card('Incremento', '${rangos['incremento_promedio']}%')),
            ],
          ),
          pw.SizedBox(height: 20),

          // Sección 2: Índice de Equidad
          _seccionTitulo('2. INDICADORES DE EQUIDAD'),
          pw.Row(
            children: [
              pw.Expanded(child: _card('Índice de Equidad', '${detalleEscala['indice_equidad']}%')),
              pw.SizedBox(width: 12),
              pw.Expanded(child: _card('Brecha Salarial Máx.', '${detalleEscala['brecha_salarial']}%')),
            ],
          ),
          pw.SizedBox(height: 20),

          // Sección 3: Masa Salarial
          _seccionTitulo('3. MASA SALARIAL POR CATEGORÍA'),
          pw.Table(
            border: pw.TableBorder.all(color: PdfColors.grey300),
            children: [
              pw.TableRow(
                decoration: pw.BoxDecoration(color: PdfColor.fromHex('6B2D8B')),
                children: [
                  _celdaHeader('Categoría'),
                  _celdaHeader('Total (S/)'),
                  _celdaHeader('Porcentaje'),
                ],
              ),
              for (final item in analisis['masa_salarial'] as List)
                pw.TableRow(children: [
                  _celda(item['categoria'].toString()),
                  _celda('S/${_formatNum(item['total'])}'),
                  _celda('${item['porcentaje']}%'),
                ]),
            ],
          ),
          pw.SizedBox(height: 20),

          // Sección 4: Distribución por Banda
          _seccionTitulo('4. DISTRIBUCIÓN POR BANDA SALARIAL'),
          pw.Table(
            border: pw.TableBorder.all(color: PdfColors.grey300),
            children: [
              pw.TableRow(
                decoration: pw.BoxDecoration(color: PdfColor.fromHex('6B2D8B')),
                children: [
                  _celdaHeader('Banda'),
                  _celdaHeader('Cantidad de Puestos'),
                  _celdaHeader('Score Promedio'),
                ],
              ),
              for (final banda in ['MASTER', 'SENIOR', 'JUNIOR'])
                pw.TableRow(children: [
                  _celda(banda),
                  _celda('${(detalleEscala['bandas'] as Map)[banda] ?? 0}'),
                  _celda('${(detalleEscala['score_promedio'] as Map)[banda] ?? 0} pts'),
                ]),
            ],
          ),
          pw.SizedBox(height: 20),

          // Sección 5: Pesos de Factores
          _seccionTitulo('5. ANÁLISIS DE PESO DE FACTORES (CALIBRACIÓN)'),
          pw.Table(
            border: pw.TableBorder.all(color: PdfColors.grey300),
            children: [
              pw.TableRow(
                decoration: pw.BoxDecoration(color: PdfColor.fromHex('6B2D8B')),
                children: [
                  _celdaHeader('Factor'),
                  _celdaHeader('Peso (%)'),
                ],
              ),
              for (final item in detalleEscala['pesos_factores'] as List)
                pw.TableRow(children: [
                  _celda(item['factor'].toString()),
                  _celda('${item['porcentaje']}%'),
                ]),
            ],
          ),
          pw.SizedBox(height: 20),

          // Sección 6: Rangos Salariales
          _seccionTitulo('6. RANGOS SALARIALES'),
          pw.Table(
            border: pw.TableBorder.all(color: PdfColors.grey300),
            children: [
              pw.TableRow(
                decoration: pw.BoxDecoration(color: PdfColor.fromHex('6B2D8B')),
                children: [
                  _celdaHeader('Nivel'),
                  _celdaHeader('Mínimo'),
                  _celdaHeader('Máximo'),
                ],
              ),
              for (final nivel in ['junior', 'senior', 'master'])
                pw.TableRow(children: [
                  _celda(nivel.toUpperCase()),
                  _celda('S/${_formatNum((rangos['rangos'] as Map)['${nivel}_min'])}'),
                  _celda('S/${_formatNum((rangos['rangos'] as Map)['${nivel}_max'])}'),
                ]),
            ],
          ),
          pw.SizedBox(height: 20),

          // Pie de página
          pw.Divider(),
          pw.Text(
            'Generado por Sistema de Gestión Remunerativa USS',
            style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey),
          ),
        ],
      ),
    );

    await Printing.layoutPdf(
      onLayout: (format) async => pdf.save(),
      name: 'Reporte_Analisis_Salarial_USS.pdf',
    );
  }

  static pw.Widget _seccionTitulo(String titulo) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 8),
      child: pw.Text(
        titulo,
        style: pw.TextStyle(
          fontSize: 14,
          fontWeight: pw.FontWeight.bold,
          color: PdfColor.fromHex('6B2D8B'),
        ),
      ),
    );
  }

  static pw.Widget _card(String label, String valor) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(label, style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey)),
          pw.SizedBox(height: 4),
          pw.Text(
            valor,
            style: pw.TextStyle(
              fontSize: 14,
              fontWeight: pw.FontWeight.bold,
              color: PdfColor.fromHex('7DC242'),
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _celdaHeader(String texto) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(
        texto,
        style: pw.TextStyle(
          color: PdfColors.white,
          fontWeight: pw.FontWeight.bold,
          fontSize: 11,
        ),
      ),
    );
  }

  static pw.Widget _celda(String texto) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(texto, style: const pw.TextStyle(fontSize: 11)),
    );
  }

  static String _formatNum(dynamic valor) {
    if (valor == null) return '0';
    final num v = valor is num ? valor : num.tryParse(valor.toString()) ?? 0;
    return v.toStringAsFixed(0);
  }
}