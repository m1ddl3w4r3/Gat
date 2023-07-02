#!/usr/bin/env python3
import base64

# Edit this line with the path to the binary file containing shellcode you are converting
with open('/home/m1ddl3w4r3/Desktop/payload.bin', 'rb') as sc_handle:
    sc_data = sc_handle.read()

# Just raw binary blog base64 encoded
encoded_raw = base64.b64encode(sc_data)
n=100
chunks = [encoded_raw[i:i+n] for i in range(0, len(encoded_raw), n)]

# Print in "standard" shellcode format \x41\x42\x43....
binary_code = ''
fs_code = ''
for byte in sc_data:
    binary_code += "\\x" + hex(byte)[2:].zfill(2)
    # this is for f#
    fs_code += "0x" + hex(byte)[2:].zfill(2) + "uy;"

binary_chunks = [binary_code[i:i+n] for i in range(0, len(binary_code), n)]


# Convert this into a C# style shellcode format
cs_shellcode = "0" + ",0".join(binary_code.split("\\")[1:])

# Base 64 encode the C# code (for use with certain payloads :))
encoded_cs = base64.b64encode(cs_shellcode.encode())

# Write out the files to disk (edit this path as needed)
with open('InjectShellCode.txt', 'w') as format_out:
    format_out.write("Binary Blob base64 encoded:\n\n")
    format_out.write(encoded_raw.decode('ascii'))
    format_out.write("\n\nStandard shellcode format:\n\n")
    format_out.write(binary_code)
    format_out.write("\n\nC# formatted shellcode:\n\n")
    format_out.write(cs_shellcode)
    format_out.write("\n\nBase64 Encoded C# shellcode:\n\n")
    format_out.write(encoded_cs.decode('ascii'))
    format_out.write("\n\nF# Shellcode:\n\n")
    format_out.write(fs_code)
    format_out.write("\n")
    format_out.write("\n\nchunk base64 Shellcode:\n\n")
    for item in chunks:
        format_out.write(f"\"{item.decode('ascii')}\"\n")
    format_out.write("\n\nChunk Standard shellcode format:\n\n")
    for item in binary_chunks:
        format_out.write(f"\"{item}\"\n")
