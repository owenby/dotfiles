
struct ray{
    float3 origin;
    float3 direction;
};

struct sphere{
    float3 centre;
    float radius;
    float3 colour;
};


__kernel void render_kernel(__global float3* output, int width, int height)
{    
    const int work_item_id = get_global_id(0);		/* the unique global id of the work item for the current pixel */
    int x_coord = work_item_id % width;					/* x-coordinate of the pixel */
    int y_coord = work_item_id / width;					/* y-coordinate of the pixel */
    
    float fx = (float)x_coord / (float)width;  /* convert int in range [0 - width] to float in range [0-1] */
    float fy = (float)y_coord / (float)height; /* convert int in range [0 - height] to float in range [0-1] */
    
    /* float aspect = width/height; */
    float aspect = 1.0;
    float viewport_h = 2.0;
    float viewport_w = aspect*viewport_h;
    float focal_length = 1.0;
    
    float3 cam_origin = (float3)(0.0,0.0,0.0);
    float3 horizontal = (float3)(viewport_w, 0.0, 0.0);
    float3 vertical = (float3)(0.0, viewport_h, 0.0);
    float3 top_left_corner = cam_origin - horizontal/2 + vertical/2 - (float3)(0.0, 0.0, focal_length);
    

    struct ray r;
    r.direction = top_left_corner + fx*horizontal - fy*vertical - cam_origin;
    r.origin = (float3)(0,0,0);
    
    struct sphere s;
    s.centre = (float3)(0.0,0.0,-3.0);
    s.radius = 0.5;
    
    float3 oc = r.origin - s.centre;

    float a = dot(r.direction, r.direction);

    float b = 2.0 * dot(oc, r.direction);
    float c = dot(oc, oc) - s.radius*s.radius;
    float discriminant = b*b - 4*a*c;
    
    float3 pixel_colour;
    if (discriminant > 0) { pixel_colour = (float3)(1.0,1.0,1.0); }        
    else                  { pixel_colour = (float3)(fy*0.6, fy*0.3, 0.5); }
    
    output[work_item_id] = pixel_colour;
    
}
