# 🌍 CarbonoStepEFC: Carbon Footprint Dashboard
Datos en grafico y Swift Data de la huella de carbono.

![](carbono_huella.mov)


## 🚀 Características Técnicas

- **Persistencia Moderna:** Implementación integral con **SwiftData**, utilizando esquemas declarativos (@Model) para la gestión del ciclo de vida de los datos sin el boilerplate tradicional de Core Data.
- **Visualización Analítica:** Dashboard interactivo construido con **Swift Charts**, que agrupa actividades por fecha y las segmenta visualmente por categorías.
- **Arquitectura Reactiva:** Sincronización automática entre la base de datos y la interfaz de usuario mediante el uso de `@Query`, eliminando la necesidad de refrescos manuales de UI.
- **Gestión CRUD Completa:** Funcionalidades para añadir registros, eliminar entradas individuales mediante gestos nativos y borrado masivo de la base de datos.


## 🛠️ Stack Tecnológico

- **SwiftUI:** Interfaz de usuario declarativa y moderna.
- **SwiftData:** Motor de persistencia de última generación.
- **Swift Charts:** Framework para la creación de gráficos de alto rendimiento.
- **Foundation:** Lógica de fechas y tipado de datos.

## 📊 Categorías Monitorizadas

La aplicación permite clasificar el impacto en cuatro áreas clave para un análisis detallado:
- 🚗 **Transporte**
- 🥗 **Alimentación**
- 🏠 **Hogar**
- ⚡ **Energía**

## 💻 Instalación y Uso

1. Crea un proyecto.
2. Utiliza el ContentView.swift de este repositorio.

> **Nota Técnica:** La aplicación requiere la inyección del contenedor de datos en la raíz:
> `.modelContainer(for: EcoActivity.self)`

```swift
import SwiftUI
import SwiftData

@main
struct CarbonoEFCApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(for: EcoActivity.self)
        }
    }
}

```

## 🧠 Aprendizajes Clave

Este proyecto me ha permitido profundizar en:
1. La simplificación de modelos de datos complejos mediante **Macros en Swift**.
2. El uso de **BarMark** y estilos de segmentación (`foregroundStyle`) para representar datos categóricos.
3. El manejo de contextos de datos (`modelContext`) para operaciones de escritura seguras y eficientes.


