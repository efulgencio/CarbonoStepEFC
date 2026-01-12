import SwiftUI
import SwiftData
import Charts

// MARK: - PERSISTENCIA (SwiftData Model)
/// @Model es un macro que automatiza la persistencia. Convierte una clase simple
/// en una entidad de base de datos SQL completa sin configurar archivos externos.
@Model
final class EcoActivity {
    // Definición de atributos que se mapearán como columnas en la base de datos
    var name: String
    var carbonImpact: Double
    var date: Date
    var category: String
    
    // El inicializador es obligatorio para que SwiftData cree los registros
    init(name: String, carbonImpact: Double, category: String) {
        self.name = name
        self.carbonImpact = carbonImpact
        self.category = category
        self.date = Date() // Se asigna automáticamente la fecha de creación
    }
}

// MARK: - INTERFAZ DE USUARIO (View Layer)
struct ContentView: View {
    // 1. modelContext: Es el "manager" de la base de datos. Se usa para insertar y borrar.
    @Environment(\.modelContext) private var modelContext
    
    // 2. @Query: Es un "Live Fetch". Realiza la consulta a la base de datos y,
    // gracias a SwiftData, refresca la UI automáticamente cada vez que los datos cambian.
    @Query(sort: \EcoActivity.date, order: .reverse) private var activities: [EcoActivity]
    
    // Propiedades de estado para controlar el flujo de la interfaz
    @State private var showingAddSheet = false
    @State private var activityName = ""
    @State private var selectedCategory = "Transporte"
    @State private var impactValue = 5.0
    
    // Lista de categorías para segmentación analítica
    let categories = ["Transporte", "Alimentación", "Hogar", "Energía"]

    var body: some View {
        NavigationStack {
            List {
                // MARK: - ANÁLISIS VISUAL (Swift Charts)
                Section("Análisis Semanal (kg CO2)") {
                    // Estado vacío: Si no hay datos, mostramos un feedback claro al usuario
                    if activities.isEmpty {
                        Text("Introduce datos para generar el gráfico")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding()
                    } else {
                        // El framework Charts procesa el array de 'activities' directamente
                        Chart {
                            ForEach(activities) { activity in
                                // BarMark: Crea barras de datos.
                                // X: Representa el tiempo (Días). Y: Representa el valor numérico (CO2).
                                BarMark(
                                    x: .value("Día", activity.date, unit: .day),
                                    y: .value("CO2", activity.carbonImpact)
                                )
                                // Segmentación visual: Asigna colores diferentes según la categoría
                                .foregroundStyle(by: .value("Categoría", activity.category))
                                .cornerRadius(4)
                            }
                        }
                        .frame(height: 200)
                        .padding(.vertical)
                        // SwiftUI Charts gestiona automáticamente los ejes y la leyenda
                    }
                }
                
                // MARK: - HISTORIAL (List View)
                Section("Registros Recientes") {
                    ForEach(activities) { activity in
                        HStack {
                            VStack(alignment: .leading) {
                                Text(activity.name).font(.headline)
                                Text(activity.category).font(.caption).foregroundColor(.secondary)
                            }
                            Spacer()
                            // Formateo de impacto a un solo decimal para limpieza visual
                            Text("\(activity.carbonImpact, specifier: "%.1f") kg").bold()
                        }
                    }
                    // Implementación de borrado por gesto (Swipe to Delete)
                    .onDelete(perform: deleteActivity)
                }
            }
            .navigationTitle("EcoPulse")
            
            // MARK: - TOOLBAR (Botones de Acción)
            .toolbar {
                // Leading: Botón destructivo para limpiar toda la base de datos
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(role: .destructive, action: clearAllData) {
                        Image(systemName: "trash")
                            .foregroundColor(activities.isEmpty ? .secondary : .red)
                    }
                    .disabled(activities.isEmpty)
                }
                
                // Trailing: Acceso al formulario de inserción
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddSheet = true }) {
                        Image(systemName: "plus.circle.fill").font(.title3)
                    }
                }
            }
            
            // MARK: - FORMULARIO DE ENTRADA (Input Layer)
            .sheet(isPresented: $showingAddSheet) {
                NavigationStack {
                    Form {
                        Section("Detalles") {
                            TextField("Actividad (ej: Vuelo, Cena...)", text: $activityName)
                            Picker("Categoría", selection: $selectedCategory) {
                                ForEach(categories, id: \.self) { Text($0) }
                            }
                        }
                        Section("Impacto Estimado") {
                            Text("\(impactValue, specifier: "%.1f") kg CO2").bold()
                            // Slider para entrada de datos táctil y rápida
                            Slider(value: $impactValue, in: 0.1...30, step: 0.1)
                        }
                    }
                    .navigationTitle("Nuevo Registro")
                    .toolbar {
                        Button("Guardar") { addActivity() }
                            .disabled(activityName.isEmpty) // Validación simple de campo vacío
                    }
                }
                .presentationDetents([.medium]) // Hoja de tamaño medio para mejor UX
            }
        }
    }
    
    // MARK: - LÓGICA CRUD (Create, Read, Update, Delete)
    
    /// Crea una nueva instancia del modelo y la inserta en el contexto de SwiftData.
    private func addActivity() {
        let newActivity = EcoActivity(name: activityName, carbonImpact: impactValue, category: selectedCategory)
        modelContext.insert(newActivity) // El guardado en disco es automático
        activityName = ""
        showingAddSheet = false
    }
    
    /// Elimina registros específicos del historial.
    private func deleteActivity(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(activities[index])
        }
    }
    
    /// Elimina masivamente todas las entradas de la entidad EcoActivity.
    private func clearAllData() {
        withAnimation {
            // SwiftData permite borrar por tipo de entidad, vaciando la tabla por completo
            try? modelContext.delete(model: EcoActivity.self)
        }
    }
}
