//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.4;

contract ParentVehicle {
    function start() public pure virtual returns (string memory) {
        string memory message = "The Vehicle has just Started";
        return message;
    }

    function accelerate() public pure virtual returns (string memory) {
        string memory message = "The Vehicle has just Accelerated";
        return message;
    }

    function stop() public pure virtual returns (string memory) {
        string memory message = "The Vehicle has just Stopped";
        return message;
    }

    function service() public pure virtual returns (string memory) {
        string memory message = "The Vehicle is being serviced";
        return message;
    }
}

contract Cars is ParentVehicle {
    function service() public pure override returns (string memory) {
        string memory message = "The Car is being serviced";
        return message;
    }
}

contract Truck is ParentVehicle {
    function service() public pure override returns (string memory) {
        string memory message = "The Truck is being serviced";
        return message;
    }
}

contract MotorCycle is ParentVehicle {
    function service() public pure override returns (string memory) {
        string memory message = "The MotorCycle is being serviced";
        return message;
    }
}

contract AltoMehran is Cars {}

contract Hino is Truck {}

contract Yamaha is MotorCycle {}

contract ServiceStation {
    function vehicleServiceCar(AltoMehran _car)
        public
        pure
        returns (string memory)
    {
        return _car.service();
    }

    function vehicleServiceTruck(Hino _truck)
        public
        pure
        returns (string memory)
    {
        return _truck.service();
    }

    function vehicleServiceMotorCycle(Yamaha _motorCycle)
        public
        pure
        returns (string memory)
    {
        return _motorCycle.service();
    }
}
