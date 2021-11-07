
#include <iostream>
#include <fstream>
#include <tuple>
#include <vector>
#include <OpenCL/opencl.h>
#include "OpenCL/cl.hpp"

#ifdef _WIN32
#include <SDL/SDL.h> /* Windows-specific SDL2 library */
#else
// #include <SDL2/SDL.h> /* macOS- and GNU/Linux-specific */
#include <OpenCL/opencl.h>
#include "OpenCL/cl.hpp"
#endif

using namespace std;
using namespace cl;

const int WIDTH = 1000;
const int HEIGHT = 1000;

cl_float4* cpu_output;
CommandQueue queue;
Kernel kernel;
Context context;
Program program;
Buffer cl_output;

void pickPlatform(Platform& platform, const vector<Platform>& platforms){
	
    if (platforms.size() == 1) platform = platforms[0];
    else{
        int input = 0;
        cout << "\nChoose an OpenCL platform: ";
        cin >> input;

        // handle incorrect user input
        while (input < 1 || input > platforms.size()){
            cin.clear(); //clear errors/bad flags on cin
            cin.ignore(cin.rdbuf()->in_avail(), '\n'); // ignores exact number of chars in cin buffer
            cout << "No such option. Choose an OpenCL platform: ";
            cin >> input;
        }
        platform = platforms[input - 1];
    }
}

void pickDevice(Device& device, const vector<Device>& devices){
	
    if (devices.size() == 1) device = devices[0];
    else{
        int input = 0;
        cout << "\nChoose an OpenCL device: ";
        cin >> input;

        // handle incorrect user input
        while (input < 1 || input > devices.size()){
            cin.clear(); //clear errors/bad flags on cin
            cin.ignore(cin.rdbuf()->in_avail(), '\n'); // ignores exact number of chars in cin buffer
            cout << "No such option. Choose an OpenCL device: ";
            cin >> input;
        }
        device = devices[input - 1];
    }
}


void initOpenCL()
{
    // Get all available OpenCL platforms (e.g. AMD OpenCL, Nvidia CUDA, Intel OpenCL)
    vector<Platform> platforms;
    Platform::get(&platforms);
    cout << "Available OpenCL platforms : " << endl << endl;
    for (int i = 0; i < platforms.size(); i++)
        cout << "\t" << i + 1 << ": " << platforms[i].getInfo<CL_PLATFORM_NAME>() << endl;

    // Pick one platform
    Platform platform;
    pickPlatform(platform, platforms);
    cout << "\nUsing OpenCL platform: \t" << platform.getInfo<CL_PLATFORM_NAME>() << endl;

    // Get available OpenCL devices on platform
    vector<Device> devices;
    platform.getDevices(CL_DEVICE_TYPE_ALL, &devices);

    cout << "Available OpenCL devices on this platform: " << endl << endl;
    for (int i = 0; i < devices.size(); i++){
        cout << "\t" << i + 1 << ": " << devices[i].getInfo<CL_DEVICE_NAME>() << endl;
        cout << "\t\tMax compute units: " << devices[i].getInfo<CL_DEVICE_MAX_COMPUTE_UNITS>() << endl;
        cout << "\t\tMax work group size: " << devices[i].getInfo<CL_DEVICE_MAX_WORK_GROUP_SIZE>() << endl << endl;
    }

    // Pick one device
    Device device;
    pickDevice(device, devices);
    cout << "\nUsing OpenCL device: \t" << device.getInfo<CL_DEVICE_NAME>() << endl;
    cout << "\t\t\tMax compute units: " << device.getInfo<CL_DEVICE_MAX_COMPUTE_UNITS>() << endl;
    cout << "\t\t\tMax work group size: " << device.getInfo<CL_DEVICE_MAX_WORK_GROUP_SIZE>() << endl;

    // Create an OpenCL context and command queue on that device.
    context = Context(device);
    queue = CommandQueue(context, device);

    // Convert the OpenCL source code to a string
    string source;
    ifstream file("opencl_kernel.cl");
    if (!file){
        cout << "\nNo OpenCL file found!" << endl << "Exiting..." << endl;
        system("PAUSE");
        exit(1);
    }
    while (!file.eof()){
        char line[256];
        file.getline(line, 255);
        source += line;
    }

    const char* kernel_source = source.c_str();

    // Create an OpenCL program by performing runtime source compilation for the chosen device
    program = Program(context, kernel_source);
    cl_int result = program.build({ device });
    if (result) std::cout << "Error during compilation OpenCL code!!!\n (" << result << ")" << std::endl;

    // Create a kernel (entry point in the OpenCL source program)
    kernel = Kernel(program, "render_kernel");
}

inline float clamp(float x){ return x < 0.0f ? 0.0f : x > 1.0f ? 1.0f : x; }

// convert RGB float in range [0,1] to int in range [0, 255]
inline int toInt(float x){ return int(clamp(x) * 255 + .5); }

inline double toDouble(float x) { return double(clamp(x) * 255 + .5); }

inline double toChar(float x){ return char(clamp(x)*255 +.5);}


void saveImage(){

    // write image to PPM file, a very simple image file format
    // PPM files can be opened with IrfanView (download at www.irfanview.com) or GIMP
    FILE *f = fopen("opencl_raytracer.ppm", "w");
    fprintf(f, "P3\n%d %d\n%d\n", WIDTH, HEIGHT, 255);

    // loop over pixels, write RGB values
    for (int i = 0; i < WIDTH * HEIGHT; i++)
        fprintf(f, "%d %d %d ",
		toInt(cpu_output[i].s[0]),
		toInt(cpu_output[i].s[1]),
		toInt(cpu_output[i].s[2]));
}

void releaseMemory(){
    // cl::ReleaseMemObject(cl_output)
}





int main(){

    initOpenCL();

    // allocate memory on CPU to hold image
    cpu_output = new cl_float3[WIDTH * HEIGHT];

    // Create image buffer on the OpenCL device
    cl_output = Buffer(context, CL_MEM_WRITE_ONLY, WIDTH * HEIGHT * sizeof(cl_float3));

    // specify OpenCL kernel arguments
    kernel.setArg(0, cl_output);
    kernel.setArg(1, WIDTH);
    kernel.setArg(2, HEIGHT);    
    // Camera arguments

    
    // every pixel in the image has its own thread or "work item",
    // so the total amount of work items equals the number of pixels
    std::size_t global_work_size = WIDTH * HEIGHT;
    // Experiment for optimality
    std::size_t local_work_size = 64;

    unsigned char * pixels = new unsigned char[WIDTH*HEIGHT*3];

    // pitch is the memory size of one row
    int texture_pitch = WIDTH * sizeof(unsigned char) * 3;
    

    // launch the kernel
    queue.enqueueNDRangeKernel(kernel, NULL, global_work_size, local_work_size);
    queue.finish();
    
    // read and copy OpenCL output to CPU
    queue.enqueueReadBuffer(cl_output, CL_TRUE, 0, WIDTH * HEIGHT * sizeof(cl_float3), cpu_output);
    
    // not optimal, SDL sucks, port functions to the kernel later
    int c=0;
    for(int i=0; i<WIDTH*HEIGHT; i++){
        unsigned char r = static_cast<unsigned char>(toInt(cpu_output[i].s[0]));
        unsigned char g = static_cast<unsigned char>(toInt(cpu_output[i].s[1]));
        unsigned char b = static_cast<unsigned char>(toInt(cpu_output[i].s[2]));
        pixels[i+0+c] = r;
        pixels[i+1+c] = g;
        pixels[i+2+c] = b;
        c = c + 2;
        }
    
        
    saveImage();
    cout << "Rendering done!\nSaved image to 'opencl_raytracer.ppm'" << endl;

// release memory
    delete[] pixels;
    delete cpu_output;

    clReleaseMemObject(cl_output());       
 
    return 0;
}
