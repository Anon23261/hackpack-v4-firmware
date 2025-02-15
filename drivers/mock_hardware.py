"""Mock hardware modules for testing without physical hardware."""


class MockGPIO:
    """Mock RPi.GPIO module."""

    BCM = "BCM"
    BOARD = "BOARD"
    IN = "IN"
    OUT = "OUT"
    HIGH = 1
    LOW = 0

    @staticmethod
    def setmode(mode):
        pass

    @staticmethod
    def setup(pin, mode):
        pass

    @staticmethod
    def input(pin):
        return 0

    @staticmethod
    def output(pin, value):
        pass

    @staticmethod
    def cleanup():
        pass


class MockSPI:
    """Mock SPI device."""

    def __init__(self):
        self.max_speed_hz = 0
        self.mode = 0

    def open(self, bus, device):
        pass

    def xfer2(self, values):
        return [0, 128]  # Mid-range value

    def close(self):
        pass


# Create mock instances
GPIO = MockGPIO()
SpiDev = MockSPI
