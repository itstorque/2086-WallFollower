## 2086-WallFollower

This is the MATLAB code for the project. Current desired structure:

# Code Structure:

 * Abstract Interface FieldObject - Levi
	 * Method draw
	 * Abstract Variable pos

 * Class Wall extends FieldObject
	 * Variable point1
	 * Variable point2

 * Class Path extends FieldObject
	 * Variable Positions
	 * Method addPosition
		 * Input: pos
	
 * Abstract Class Robot extends Field Object
	 * Variable Theta
	 * Variable Velocity
	 * Variable dTheta
	 * Abstract Method splicedData
		 * Input: List of walls
		 * Output: left,front,right
	 * Method findDistanceCloud
		 * Input: List of walls, dTheta
		 * Output: List of points

 * Method DrawField
	 * Input: List of field objects, figure
	 * Output: Figure

 * Abstract Class Controller
	 * Abstract Method Algorithm
		 * Input: Robot, walls
		 * Output: Pseduo-force
	 * Abstract Method Plant
		 * Input: Pseduo-force
		 * Output: DeltaTheta
 	 * Method canDrive
		 * Input (Robot) Robot, List(FieldObject) walls
		 * Output boolean
	 * Method run
		 * Inputs: (Robot) Robot, List(FieldObject) walls, (double) time, (boolean) doDraw
		 * Output: (Robot) Robot, (boolean) didCollide, list of robot coords

#Members
* Interface Field Object - Levi
	 * Method draw
	 * Abstract Variable position
* Class Obstacle implements Field Object
	
* Class Robot implements Field Object
	 * Variable Splice Parameters
	 * Variable Size

* Method DrawField
	 * Input: List of field objects, figure
	 * Output: Figure

* Abstract Class Controller
	 * Abstract Method Algorithm
		 * Input: Distance cloud, robot
		 * Output: Pseduo-force
	 * Method Can_Drive
		 * Input List of field objects
		 * Output boolean
	 * Method Generate_path
		 * Inputs: Robot, list of walls, time to model, boolean draw
		 * Output: List of (List of field objects), did collide, list of robot coords

* Class Utilities
	 * Method findDistanceCloud
		 * Input: List of walls, Robot, angular increment
		 * Output: List of points
	 * Method LidarSplice
		 * Input: distance cloud, Splice Parameters
		 * Output: Spliced arrays


# Members
 - Levi Gershon
 - Tareq Dandachi
 - Jason Daniels