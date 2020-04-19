## 2086-WallFollower

This is the MATLAB code for the project. Current desired structure:

#Code Structure:

 - Interface Field Object - Levi
	Method draw
	Abstract Variable position
 - Class Obstacle implements Field Object
	
 - Class Robot implements Field Object
	Variable Splice Parameters
	Variable Size

 - Method DrawField
	Input: List of field objects, figure
	Output: Figure

 - Abstract Class Controller
	Abstract Method Algorithm
		Input: Distance cloud, robot
		Output: Pseduo-force
 	Method Can_Drive
		Input List of field objects
		Output boolean
	Method Generate_path
		Inputs: Robot, list of walls, time to model, boolean draw
		Output: List of (List of field objects), did collide, list of robot coords

 - Class Utilities
	Method findDistanceCloud
		Input: List of walls, Robot, angular increment
		Output: List of points
	Method LidarSplice
		Input: distance cloud, Splice Parameters
		Output: Spliced arrays


#Members
 - Levi Gershon
 - Tareq Dandachi
 - Jason Daniels
