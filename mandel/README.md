# Render del Set di Mandelbrot

Genera un'immagine in formato ppm (P6).

## Compilazione
```
make
```

## Generazione immagine
```
./mandel [ width height [ n_iter ] ]
```

Parametri di default:
- width: 2000
- height: 1000
- n_iter: 1000

L'immagine viene scritta su `stdout`.
