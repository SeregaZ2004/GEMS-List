# GEMS-List

list of unpacked GEMS banks for using with Online GEMS GUI for Sega Mega Drive games.

name//url//size



GEMSPointers.txt

list of addresses, where you need to set addresses of new GEMS banks at the end of rom file.

CRC32//write//sampls//sequen//envelp//patchs//bytes//comments

CRC32 - checksum for rom detection
write - place, where to start write new GEMS banks. actualy it is end of rom file, but can be end of data inside a rom - place, where space is filled FF FF FF... values at the end of rom file.
samples, sequences, envelopes, patches - addresses, where is need to set addresses of new GEMS banks
bytes - 2 or 3 bytes. what system use GEMS pointers for sequences and samples.
comments - some additional data for special cases. like MK3 & WWF Arcade - GEMS x 2 (8 banks) + DPCM type samples, with 6.5k frequecy 4 bit samples, that can have multisampling. like Comix Zone & Ooze - ADPCM samples. like Zero Tolerance - sequences bank have only melodies, but instruments and samples have melodies and SFX instruments and envelopes. SFX no have sequences - but starts from athother place - special tables of sound. it is not GEMS table, but use GEMS's instruments and samples. and etc special cases.
