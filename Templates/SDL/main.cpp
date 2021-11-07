

// LINKER_FLAGS = -lSDL2

#include <iostream>
#include <fstream>
#include <tuple>
#include <vector>
#include <OpenCL/opencl.h>
#include "SDL2/SDL_pixels.h"
#include "SDL2/SDL_render.h"
#include "SDL2/SDL_timer.h"

#ifdef _WIN32
#include <SDL/SDL.h> /* Windows-specific SDL2 library */
#else
// #include <SDL2/SDL.h> /* macOS- and GNU/Linux-specific */
#include "SDL2/SDL.h" // for local SDL headers
#endif

const int WIDTH = 1000;
const int HEIGHT = 1000;

SDL_Window * window;
SDL_Renderer *renderer;
SDL_Texture *texture;

void inline initSDL(){

    if (SDL_Init(SDL_INIT_VIDEO) != 0) {
        fprintf(stderr, "SDL failed to initialise: %s\n", SDL_GetError());
        exit(0);
    }

    // Creates an SDL window
    window = SDL_CreateWindow("Talpidae",              /* Title of the SDL window */
                              SDL_WINDOWPOS_UNDEFINED, /* Position x of the window */
                              SDL_WINDOWPOS_UNDEFINED, /* Position y of the window */
                              WIDTH,  /* Width of the window in pixels */
                              HEIGHT, /* Height of the window in pixels */
                              SDL_WINDOW_RESIZABLE
                              //SDL_WINDOW_BORDERLESS /* To remove title bar */
                              );                                     /* Additional flag(s) */

    /* Checks if window has been created; if not, exits program */
    if (window == NULL) {
        fprintf(stderr, "SDL window failed to initialise: %s\n", SDL_GetError());
        exit(0);
    }
  
    // create renderer
    renderer = SDL_CreateRenderer(window,
                                  -1,
                                  SDL_RENDERER_ACCELERATED | SDL_RENDERER_PRESENTVSYNC);
    
    if (renderer == NULL) {
        SDL_Log("Unable to create renderer: %s", SDL_GetError());
        exit(0);
    }
    
    SDL_RenderSetLogicalSize(renderer, WIDTH, HEIGHT);

    // create texture
    texture = SDL_CreateTexture(
                                renderer,
                                SDL_PIXELFORMAT_RGB24,
                                // SDL_PIXELFORMAT_ARGB8888, // Apparently fast?
                                // SDL_PIXELFORMAT_RGB888,
                                SDL_TEXTUREACCESS_STREAMING,
                                WIDTH,
                                HEIGHT);
    if (texture == NULL) {
        SDL_Log("Unable to create texture: %s", SDL_GetError());
        exit(0);
    }
    SDL_UnlockTexture(texture);

    // Frame rate display https://stackoverflow.com/questions/33304351/sdl2-fast-pixel-manipulation
    SDL_RendererInfo info;
    SDL_GetRendererInfo( renderer, &info );
    std::cout << "Renderer name: " << info.name << std::endl;
    std::cout << "Texture formats: " << std::endl;
    for( Uint32 i = 0; i < info.num_texture_formats; i++ )
        {
            std::cout << SDL_GetPixelFormatName( info.texture_formats[i] ) << std::endl;
        }
}




int main(){

    initSDL();

    unsigned char * pixels = new unsigned char[WIDTH*HEIGHT*3];

    // pitch is the memory size of one row
    int texture_pitch = WIDTH * sizeof(unsigned char) * 3;
    
    unsigned int frames = 0;
    Uint64 start = SDL_GetPerformanceCounter();

    // Begin program loop
    SDL_Event e;
    bool quit = false;
    while (!quit) {
        SDL_RenderClear(renderer);
        
        while (SDL_PollEvent(&e)) {
            if (e.type == SDL_QUIT) {
                quit = true;
            }
            if (e.type == SDL_KEYDOWN) {
                switch(e.key.keysym.sym){
                case SDLK_LEFT:
                    quit = true;
                    // TODO: add user controls
                }
            }
        }


        // Update the SDL texture
        // lock texture here
        // SDL_LockTexture(texture, NULL,  (void **) &pixels, &texture_pitch);
        SDL_UpdateTexture(texture, NULL, pixels, texture_pitch);        
        SDL_RenderCopy(renderer, texture, NULL, NULL);
        SDL_RenderPresent(renderer);
        // SDL_UnlockTexture(texture);

        // Get framerates
        frames++;
        const Uint64 end = SDL_GetPerformanceCounter();
        const static Uint64 freq = SDL_GetPerformanceFrequency();
        const double seconds = ( end - start ) / static_cast< double >( freq );
        if( seconds > 2.0 ) {
            std::cout
                << frames << " frames in "
                << std::setprecision(1) << std::fixed << seconds << " seconds = "
                << std::setprecision(1) << std::fixed << frames / seconds << " FPS ("
                << std::setprecision(3) << std::fixed << ( seconds * 1000.0 ) / frames << " ms/frame)"
                << std::endl;
            start = end;
            frames = 0;
        }

        
    }

    
    // Free memory
    SDL_DestroyWindow(window);
    SDL_DestroyTexture(texture);
    SDL_DestroyRenderer(renderer);
    // Shuts down all SDL subsystems
    SDL_Quit();
    
    return 0;
}
