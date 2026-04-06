#include <iostream>
#include <vector>
#include <list>
#include <iomanip>
#include <fstream>
#include <string>

using namespace std;

/**
 * Estructura que representa una linea de cache (unidad minima de almacenamiento).
 * Incluye el bit de validez y la etiqueta (tag).
 */
struct CacheLine {
    bool valid;       // Indica si la linea contiene datos cargados de memoria
    unsigned int tag; // Identificador unico del bloque de memoria principal
    CacheLine(bool v, unsigned int t) : valid(v), tag(t) {}
};

/**
 * Clase principal que simula el comportamiento de una memoria cache.
 * Puede configurarse como mapeo directo o asociativa por vias.
 */
class CacheSimulator {
private:
    unsigned int cacheSize, blockSize, ways, numSets;
    // La cache se modela como un vector de listas:
    // El vector representa los conjuntos (sets) y la lista representa las vias (ways).
    vector<list<CacheLine> > cache; 
    long long hits, misses;

public:
    /**
     * Constructor del simulador.
     * Calcula el numero de conjuntos basado en la asociatividad (vias)
     */
    CacheSimulator(unsigned int cSize, unsigned int bSize, unsigned int w) 
        : cacheSize(cSize), blockSize(bSize), ways(w), hits(0), misses(0) {
        
        // Formula fundamental: NumSets = TamanoTotal / (TamanoBloque * Vias)
        numSets = cacheSize / (blockSize * ways);
        cache.resize(numSets);
    }

    /**
     * Tecnica de Prefetching: Anticipa la carga de datos cercanos en espacio
     * Si se accede al bloque N, esta funcion intenta cargar el bloque N+1.
     */
    void prefetch(unsigned int address) {
        unsigned int nextAddr = address + blockSize; // Direccion del bloque siguiente
        unsigned int blockAddr = nextAddr / blockSize;
        unsigned int setIndex = blockAddr % numSets;
        unsigned int tag = blockAddr / numSets;

        list<CacheLine>& currentSet = cache[setIndex];
        // Si el bloque ya existe en el conjunto, no se hace nada
        for (list<CacheLine>::iterator it = currentSet.begin(); it != currentSet.end(); ++it) {
            if (it->valid && it->tag == tag) return; 
        }

        // Si el conjunto esta lleno, expulsamos el menos usado (el ultimo de la lista)
        if (currentSet.size() >= (size_t)ways) currentSet.pop_back();
        // Insertamos el nuevo bloque al frente (MRU - Most Recently Used)
        currentSet.push_front(CacheLine(true, tag));
    }

    /**
     * Funcion de acceso principal. Simula la busqueda en cache y el reemplazo LRU
     * @param address Direccion de memoria a consultar.
     * @param enablePrefetch Indica si se debe activar la carga anticipada tras el acceso.
     */
    bool access(unsigned int address, bool enablePrefetch) {
        // Segmentacion de la direccion: Tag, Indice y Offset (implicito en blockAddr)
        unsigned int blockAddr = address / blockSize;
        unsigned int setIndex = blockAddr % numSets; // Determina la fila (set)
        unsigned int tag = blockAddr / numSets;      // Determina la etiqueta identificadora

        list<CacheLine>& currentSet = cache[setIndex];
        bool found = false;

        // BUSQUEDA: Se recorren las vias del conjunto seleccionado
        for (list<CacheLine>::iterator it = currentSet.begin(); it != currentSet.end(); ++it) {
            if (it->valid && it->tag == tag) {
                hits++;
                found = true;
                
                // POLITICA LRU: Mover el elemento encontrado al frente (ahora es el mas reciente) 
                CacheLine foundLine = *it;
                currentSet.erase(it);
                currentSet.push_front(foundLine);
                break;
            }
        }

        // FALLO (Miss): El dato no esta en cache, hay que "traerlo" de memoria
        if (!found) {
            misses++;
            // Si no hay vias libres, expulsamos la linea LRU (al final de la lista)
            if (currentSet.size() >= (size_t)ways) currentSet.pop_back();
            // Se inserta la nueva linea al frente
            currentSet.push_front(CacheLine(true, tag));
        }

        // Si el prefetching esta habilitado, intentamos cargar el bloque siguiente
        if (enablePrefetch) prefetch(address);
        return found;
    }

    /**
     * Muestra el analisis estadistico final de rendimiento
     */
    void printFinalStats(string mode) {
        double total = hits + misses;
        double hitRate = (total > 0) ? (hits / total) * 100 : 0;
        
        cout << left << setw(28) << mode << " | "
             << "Hits: " << setw(4) << hits << " | "
             << "Misses: " << setw(4) << misses << " | "
             << "Hit Rate: " << fixed << setprecision(2) << hitRate << "%" << endl;
    }
};

int main() {
    // Configuracion de hardware simulado basada en los requerimientos 
    unsigned int cSize = 1024; // Cache de 1KB
    unsigned int bSize = 16;   // Bloques de 16 bytes
    
    // Lectura de archivo de trazas de memoria
    ifstream archivo("direcciones.txt");
    if (!archivo.is_open()) {
        cerr << "Error: No se pudo abrir direcciones.txt" << endl;
        return 1;
    }

    vector<unsigned int> trace;
    unsigned int addr;
    // Se cargan las direcciones hexadecimales en un vector para su procesamiento
    while (archivo >> hex >> addr) trace.push_back(addr);
    archivo.close();

    // Creacion de los 4 escenarios de prueba para el analisis comparativo 
    CacheSimulator dm(cSize, bSize, 1);    // Mapeo Directo (1 via)
    CacheSimulator sa2(cSize, bSize, 2);   // Asociativa de 2 vias
    CacheSimulator sa4(cSize, bSize, 4);   // Asociativa de 4 vias
    CacheSimulator sa4pf(cSize, bSize, 4); // Asociativa de 4 vias con Prefetching activo

    // Encabezado de la tabla de seguimiento paso a paso
    cout << "\nTABLA DE SEGUIMIENTO PASO A PASO" << endl;
    cout << left << setw(12) << "Direccion" 
         << setw(12) << "Directo" 
         << setw(12) << "Asoc-2" 
         << setw(12) << "Asoc-4" 
         << setw(12) << "Asoc-4+PF" << endl;
    cout << string(60, '-') << endl;

    // Procesamiento de cada direccion de la traza en todos los simuladores
    for (size_t i = 0; i < trace.size(); ++i) {
        bool rDM = dm.access(trace[i], false);
        bool rSA2 = sa2.access(trace[i], false);
        bool rSA4 = sa4.access(trace[i], false);
        bool rSA4PF = sa4pf.access(trace[i], true);

        // Salida formateada para comparar aciertos y fallos en cada paso
        cout << "0x" << hex << left << setw(10) << trace[i] 
             << setw(12) << (rDM ? "HIT" : "MISS") 
             << setw(12) << (rSA2 ? "HIT" : "MISS") 
             << setw(12) << (rSA4 ? "HIT" : "MISS") 
             << setw(12) << (rSA4PF ? "HIT" : "MISS") << dec << endl;
    }

    // Presentacion del analisis comparativo final sustentado 
    cout << "\n" << string(75, '=') << endl;
    cout << "                    ANALISIS COMPARATIVO FINAL" << endl;
    cout << string(75, '=') << endl;
    dm.printFinalStats("Mapeo Directo");
    sa2.printFinalStats("Asociativo 2 Vias");
    sa4.printFinalStats("Asociativo 4 Vias");
    sa4pf.printFinalStats("Asociativo 4 Vias + Prefetch");
    cout << string(75, '=') << endl;

    return 0;
}