

#ifdef PIXEL

uniform float t;

const float pink_r = 231.0 / 255.0;
const float pink_g = 74.0 / 255.0;
const float pink_b = 153.0 / 255.0;

const float blue_r = 39.0 / 255.0;
const float blue_g = 170.0 / 255.0;
const float blue_b = 224.0 / 255.0;

const float black_r = 0.1;
const float black_g = 0.1;
const float black_b = 0.15;


const vec2 bubblePositions[64] = vec2[](
	vec2(0.15, 0.53),
	vec2(0.15, 0.71),
	vec2(-0.01, 0.98),
	vec2(0.14, 0.92),
	vec2(-0.00, 0.53),
	vec2(0.04, 0.79),
	vec2(0.20, 0.81),
	vec2(0.04, 0.65),
	vec2(0.27, 0.64),
	vec2(0.20, 1.00),
	vec2(0.31, 0.50),
	vec2(0.20, 0.43),
	vec2(0.54, 0.21),
	vec2(0.03, 0.16),
	vec2(0.16, 0.26),
	vec2(0.69, 0.90),
	vec2(0.34, 0.81),
	vec2(0.02, 0.30),
	vec2(0.40, 0.32),
	vec2(0.53, 1.00),
	vec2(0.43, 0.96),
	vec2(0.49, 0.84),
	vec2(0.44, 0.44),
	vec2(0.39, 0.67),
	vec2(0.60, 0.82),
	vec2(0.59, 0.54),
	vec2(0.56, 0.39),
	vec2(0.06, 0.41),
	vec2(0.70, 0.63),
	vec2(0.53, 0.67),
	vec2(0.71, 0.45),
	vec2(0.37, 0.21),
	vec2(0.31, 0.92),
	vec2(0.64, 0.30),
	vec2(0.47, 0.56),
	vec2(0.26, 0.32),
	vec2(0.75, 1.00),
	vec2(1.00, 0.73),
	vec2(0.91, 0.92),
	vec2(0.33, -0.00),
	vec2(0.52, -0.01),
	vec2(0.02, 0.00),
	vec2(1.00, 0.35),
	vec2(1.01, 0.11),
	vec2(0.74, 0.01),
	vec2(0.92, 0.04),
	vec2(0.89, 0.41),
	vec2(0.95, 0.52),
	vec2(0.86, 0.80),
	vec2(0.80, 0.54),
	vec2(1.03, 0.98),
	vec2(0.15, 0.12),
	vec2(0.90, 0.65),
	vec2(0.38, 0.08),
	vec2(0.16, 0.02),
	vec2(0.91, 0.18),
	vec2(0.81, 0.11),
	vec2(0.72, 0.20),
	vec2(0.65, 0.09),
	vec2(0.88, 0.30),
	vec2(0.75, 0.75),
	vec2(0.50, 0.10),
	vec2(0.28, 0.14),
	vec2(0.75, 0.32)
);


vec4 effect(vec4 color, Image tex, vec2 texture_coords, vec2 screen_coords) {
	float length = sqrt(love_ScreenSize.x * love_ScreenSize.x + love_ScreenSize.y * love_ScreenSize.y);
	float grow_speed = length * 0.4 * 1.25; // how quickly a bubble grows in pixels per second
	float fill_speed = length * 0.25 * 1.25; // should be a similar but not equal to grow_speed

	// calculate distance to the closest bubble
	float disToBubble = length * 2;
	float diffx;
	float diffy;
	float dis;
	for (int i = 0; i < 64; ++i) { // is it very naive to loop through 64 elements for every pixels? yes, but idk a better approach
		diffx = bubblePositions[i].x * love_ScreenSize.x - screen_coords.x;
		diffy = bubblePositions[i].y * love_ScreenSize.y - screen_coords.y;
		dis = sqrt(diffx * diffx + diffy * diffy);
		if (dis < disToBubble) {
			disToBubble = dis;
		}
	}

	// calculate distance to top-left and bottom-right corner
	float topLeftDistance = sqrt(screen_coords.x * screen_coords.x + screen_coords.y * screen_coords.y);
	float bottomRightDistance = sqrt((love_ScreenSize.x - screen_coords.x) * (love_ScreenSize.x - screen_coords.x) + (love_ScreenSize.y - screen_coords.y) * (love_ScreenSize.y - screen_coords.y));

	float disToCorner = min(topLeftDistance, bottomRightDistance);

	if (disToCorner < fill_speed * t) { // you are in range of being capable to grow
		// check if enough time has passed to the closest bubble
		float beenGrowingFor = t - (disToCorner / fill_speed);
		float amountGrown = beenGrowingFor * grow_speed;
		if (amountGrown > disToBubble) {
			if (topLeftDistance < bottomRightDistance) {
				return vec4(blue_r, blue_g, blue_b, 1.0);
			} else {
				return vec4(pink_r, pink_g, pink_b, 1.0);
			}
		}
	}

	return vec4(black_r, black_g, black_b, 1.0);
}



#endif
