# basic-asynchronous-FIFO
Asynchronous FIFO is used to synchronize between two different clock domains when there is a constant steam of data, one domain is sending data and the other is receiving the data. In this case there is no possibility of using simple synchronizers because by the time that the first signal will be synchronized few other will be lost.

The FIFO consists of internal memory that can be written by one clock domain and read by the second. There is a need of synchronizing the read and the write pointers while also keep track on full and the empty flags.

In this design I will use the same uncertainty model that was written by one of my university teachers Mr. Rafael Gantz, also I will use some modules that I used in the bus synchronization repository namely the gray code synchronizer.

The depth of the FIFO memory can be calculated like this:
FIFO depth=data burst length-(time requried for writing-FIFO synchronization delay)/(receiving clock)+2
In this design there are 2 addresses that are unreachable

