import 'package:flutter/material.dart';

void main() {
  runApp(const CalculadoraApp());
}

class CalculadoraApp extends StatefulWidget {
  const CalculadoraApp({super.key});

  @override
  State<CalculadoraApp> createState() => _CalculadoraAppState();
}

class _CalculadoraAppState extends State<CalculadoraApp> {
  bool modoNoturno = true;

  void alternarTema() {
    setState(() {
      modoNoturno = !modoNoturno;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Calculadora',
      home: Calculadora(
        modoNoturno: modoNoturno,
        alternarTema: alternarTema,
      ),
    );
  }
}

class Calculadora extends StatefulWidget {
  final bool modoNoturno;
  final VoidCallback alternarTema;

  const Calculadora({
    super.key,
    required this.modoNoturno,
    required this.alternarTema,
  });

  @override
  State<Calculadora> createState() => _CalculadoraState();
}

class _CalculadoraState extends State<Calculadora> {
  String display = '0';

  double? primeiroNumero;
  String? operador;
  bool novoNumero = false;

  // ==========================
  // ADICIONAR NÚMERO
  // ==========================

  void adicionarNumero(String numero) {
    setState(() {
      if (display == 'Erro' || novoNumero || display == '0') {
        display = numero;
        novoNumero = false;
      } else {
        display += numero;
      }
    });
  }

  // ==========================
  // PONTO
  // ==========================

  void adicionarPonto() {
    setState(() {
      if (display == 'Erro' || novoNumero) {
        display = '0.';
        novoNumero = false;
      } else if (!display.contains('.')) {
        display += '.';
      }
    });
  }

  // ==========================
  // OPERADOR
  // ==========================

  void escolherOperador(String novoOperador) {
    double? numero = double.tryParse(display);

    if (numero == null) {
      return;
    }

    setState(() {
      primeiroNumero = numero;
      operador = novoOperador;
      novoNumero = true;
    });
  }

  // ==========================
  // CALCULAR
  // ==========================

  void calcularResultado() {
    if (primeiroNumero == null || operador == null) {
      return;
    }

    double? segundoNumero = double.tryParse(display);

    if (segundoNumero == null) {
      return;
    }

    double resultado = 0;

    switch (operador) {
      case '+':
        resultado = primeiroNumero! + segundoNumero;
        break;

      case '-':
        resultado = primeiroNumero! - segundoNumero;
        break;

      case '×':
        resultado = primeiroNumero! * segundoNumero;
        break;

      case '÷':
        if (segundoNumero == 0) {
          setState(() {
            display = 'Erro';
            primeiroNumero = null;
            operador = null;
            novoNumero = true;
          });
          return;
        }

        resultado = primeiroNumero! / segundoNumero;
        break;
    }

    setState(() {
      display = formatarNumero(resultado);
      primeiroNumero = null;
      operador = null;
      novoNumero = true;
    });
  }

  // ==========================
  // PORCENTAGEM
  // ==========================

  void porcentagem() {
    double? numero = double.tryParse(display);

    if (numero == null) {
      return;
    }

    setState(() {
      display = formatarNumero(numero / 100);
      novoNumero = true;
    });
  }

  // ==========================
  // MAIS OU MENOS
  // ==========================

  void inverterSinal() {
    if (display == '0' || display == 'Erro') {
      return;
    }

    setState(() {
      if (display.startsWith('-')) {
        display = display.substring(1);
      } else {
        display = '-$display';
      }
    });
  }

  // ==========================
  // APAGAR
  // ==========================

  void apagar() {
    setState(() {
      if (display == 'Erro') {
        display = '0';
        return;
      }

      if (display.length > 1) {
        display = display.substring(0, display.length - 1);
      } else {
        display = '0';
      }
    });
  }

  // ==========================
  // LIMPAR
  // ==========================

  void limpar() {
    setState(() {
      display = '0';
      primeiroNumero = null;
      operador = null;
      novoNumero = false;
    });
  }

  // ==========================
  // FORMATAR NÚMERO
  // ==========================

  String formatarNumero(double numero) {
    if (numero == numero.roundToDouble()) {
      return numero.toInt().toString();
    }

    return numero
        .toStringAsFixed(8)
        .replaceFirst(RegExp(r'0+$'), '');
  }

  // ==========================
  // BOTÃO DA CALCULADORA
  // ==========================

  Widget botao(
    String texto, {
    bool operador = false,
    bool igual = false,
  }) {
    final bool noturno = widget.modoNoturno;

    Color fundo;

    if (igual) {
      fundo = const Color(0xFF8B5CF6);
    } else if (operador) {
      fundo = noturno
          ? const Color(0xFF332B47)
          : const Color(0xFFE9E0FF);
    } else {
      fundo = noturno
          ? const Color(0xFF242424)
          : const Color(0xFFF1F1F1);
    }

    Color corTexto;

    if (igual) {
      corTexto = Colors.white;
    } else {
      corTexto = noturno
          ? Colors.white
          : const Color(0xFF202020);
    }

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: AspectRatio(
          aspectRatio: 1.15,
          child: ElevatedButton(
            onPressed: () {
              if (texto == 'C') {
                limpar();
              } else if (texto == '⌫') {
                apagar();
              } else if (texto == '+/-') {
                inverterSinal();
              } else if (texto == '%') {
                porcentagem();
              } else if (texto == '=') {
                calcularResultado();
              } else if (texto == '.') {
                adicionarPonto();
              } else if (['+', '-', '×', '÷'].contains(texto)) {
                escolherOperador(texto);
              } else {
                adicionarNumero(texto);
              }
            },
            style: ElevatedButton.styleFrom(
              elevation: 0,
              backgroundColor: fundo,
              foregroundColor: corTexto,
              padding: EdgeInsets.zero,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(22),
              ),
            ),
            child: Text(
              texto,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w500,
                color: corTexto,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ==========================
  // TELA
  // ==========================

  @override
  Widget build(BuildContext context) {
    final bool noturno = widget.modoNoturno;

    return Scaffold(
      backgroundColor: noturno
          ? const Color(0xFF111111)
          : const Color(0xFFF8F8F8),

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
          ),

          child: Column(
            children: [
              // ========================
              // TOPO
              // ========================

              SizedBox(
                height: 55,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: noturno
                            ? const Color(0xFF242424)
                            : const Color(0xFFEDEDED),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: IconButton(
                        onPressed: widget.alternarTema,
                        icon: Icon(
                          noturno
                              ? Icons.light_mode
                              : Icons.dark_mode,
                          color: noturno
                              ? Colors.white
                              : Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // ========================
              // DISPLAY
              // ========================

              Expanded(
                flex: 2,
                child: Container(
                  width: double.infinity,
                  alignment: Alignment.bottomRight,
                  padding: const EdgeInsets.only(
                    right: 15,
                    bottom: 25,
                  ),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerRight,
                    child: Text(
                      display,
                      style: TextStyle(
                        fontSize: 64,
                        fontWeight: FontWeight.w300,
                        color: noturno
                            ? Colors.white
                            : const Color(0xFF202020),
                      ),
                    ),
                  ),
                ),
              ),

              // ========================
              // BOTÕES
              // ========================

              Expanded(
                flex: 5,
                child: Column(
                  children: [
                    Row(
                      children: [
                        botao('C'),
                        botao('+/-'),
                        botao('%'),
                        botao(
                          '÷',
                          operador: true,
                        ),
                      ],
                    ),

                    Row(
                      children: [
                        botao('7'),
                        botao('8'),
                        botao('9'),
                        botao(
                          '×',
                          operador: true,
                        ),
                      ],
                    ),

                    Row(
                      children: [
                        botao('4'),
                        botao('5'),
                        botao('6'),
                        botao(
                          '-',
                          operador: true,
                        ),
                      ],
                    ),

                    Row(
                      children: [
                        botao('1'),
                        botao('2'),
                        botao('3'),
                        botao(
                          '+',
                          operador: true,
                        ),
                      ],
                    ),

                    Row(
                      children: [
                        botao('.'),
                        botao('0'),
                        botao('⌫'),
                        botao(
                          '=',
                          igual: true,
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  } 
}