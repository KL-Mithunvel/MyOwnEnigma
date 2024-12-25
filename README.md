ADE


ARTY S7 (FPGA) Based Enigma Machine Replica
Author:
Date: 12/11/24

Abstract
This project presents a modern replica of the Enigma machine, implemented using the Arty S7 FPGA board and programmed in Verilog. The primary objective is to recreate the cryptographic functions of the Enigma machine in hardware, capturing its historical significance while enhancing its accessibility and interactivity. By combining custom-built hardware components—such as a keyboard and LED-based light-up board—with the FPGA’s computational power, this project offers a hands-on experience with encryption fundamentals. 

  

 
 ~


In the process of creating our own Enigma machine, we also explored various versions of the Enigma, including Enigma and the Paper Enigma.  We studied their working principles, encryption mechanisms, and the unique features that defined each version. This deep dive allowed us to understand how these systems operated historically and provided insights into implementing their functionality in a modernized form using FPGA technology. The upcoming sections discuss these versions in detail, showcasing how they inspired and influenced the development of our own Enigma replica.
                           
 INTRODUCTION

The Enigma machine was a cipher device used by Germany during World War II to encode and decode secret messages. Invented by Arthur Scherbius in the 1920s, it featured a system of rotors and a plugboard that created complex letter substitutions. Each rotor scrambled the alphabet, and their positions changed with every keypress, ensuring the cipher was different each time. The plugboard added further variability by swapping pairs of letters. Despite its complexity, the machine was eventually cracked by Allied cryptanalysts, notably Alan Turing and his team at Bletchley Park, which played a critical role in shortening the war.

The Enigma machine worked by scrambling letters through a series of mechanical and electrical components to encrypt messages. It had a keyboard, rotors, a reflector, and a plugboard. When a key was pressed, an electrical current passed through the plugboard, which swapped certain letters, and then through multiple rotors, which rotated after each keypress to change the cipher continuously. The current then reached a reflector, which reversed the path, sending the signal back through the rotors and plugboard, ultimately lighting up a letter on the output panel. This complex mechanism ensured that the same letter would never encrypt to itself, making the cipher highly intricate.

________________________________________Objective
The main objective was to retain the core cryptographic functions of the original Enigma machine, including encoding and decoding messages using a rotor-based encryption mechanism. To enhance the user interface, the project includes a custom-built keyboard and light-up board, creating an authentic interaction and visual feedback for each encoded letter. This setup aims to deepen understanding of digital logic, FPGA programming, and encryption mechanisms.



Enigma in WW2

The Enigma machine, a cipher device used by Nazi Germany during World War II, was a groundbreaking tool for encrypting and decrypting military communications. It operated through a complex system of rotating mechanical rotors, which substituted letters based on their internal wiring. Each key press sent an electrical signal through the machine’s plugboard, rotors, and reflector, creating a scrambled output letter. The machine's genius lay in its dynamic encryption: every key press caused the rotors to rotate, changing the wiring pathway and ensuring that identical letters typed consecutively were encrypted into different characters.
The plugboard added an additional layer of encryption by swapping specific letter pairs before and after the rotor processing, dramatically increasing the number of possible encryption combinations. The reflector, another key component, bounced the signal back through the rotors in reverse, which meant the same machine could encrypt and decrypt messages if configured identically. Operators used daily key sheets that specified rotor settings, their order, starting positions, and plugboard pairings. With billions of possible combinations, the Enigma seemed unbreakable.
However, the Allied forces, building on early breakthroughs by Polish cryptographers, cracked the Enigma’s code using innovative techniques and machines like the Bombe, developed by Alan Turing and his team at Bletchley Park. This allowed the Allies to intercept and decode German military orders, giving them a decisive advantage in key battles and shortening the war. The Enigma’s seemingly impenetrable encryption, combined with its critical role in wartime communications, makes it one of the most fascinating cryptographic devices in history.

Working of ww2 enigma
The Enigma machine's operation involved several intricate steps that worked together to encrypt and decrypt messages. Here's a detailed breakdown of its full working process:
1.	Input via Keyboard:
When an operator pressed a key, it initiated the encryption process. Each keypress generated an electrical signal corresponding to the selected letter. This signal entered the machine, beginning its journey through the various encryption components.
2.	Plugboard Substitution:
The signal first passed through the plugboard (Steckerbrett), which swapped specific letter pairs based on its wiring configuration. For example, if 'A' was paired with 'M' on the plugboard, pressing 'A' would send the signal to 'M' before entering the rotors. This step added a layer of encryption by introducing custom mappings determined by the operator's configuration.
3.	Rotor Encryption:
After the plugboard, the signal traveled through a series of rotors, which were the heart of the Enigma's encryption process. Each rotor had a unique internal wiring pattern that substituted one letter for another. As the signal passed through the rotors, it underwent multiple substitutions based on their wiring.
o	Rotor Stepping: After every keypress, the rightmost rotor would step forward one position, changing the wiring path for the next signal. When the rightmost rotor completed a full rotation, it caused the next rotor to step, similar to a mechanical odometer. This dynamic movement ensured that each keypress produced a different encryption pattern.
4.	Reflector Transformation:
Once the signal passed through all the rotors, it reached the reflector, a fixed component that redirected the signal back through the rotors in reverse order. The reflector substituted each letter based on its own fixed wiring and ensured that the encryption process was symmetric, meaning the same machine configuration could both encrypt and decrypt a message.
5.	Reverse Rotor Path:
The reflected signal traveled back through the rotors, undergoing another series of substitutions based on their reversed wiring paths. The returning signal’s path depended on the current rotor positions, which had already shifted after the keypress.
6.	Plugboard Output:
After passing back through the rotors, the signal returned to the plugboard. Here, it underwent another letter substitution based on the plugboard's configuration.
7.	Output via Lampboard:
Finally, the signal illuminated a letter on the lampboard, which represented the encrypted version of the pressed key. For example, if the input was 'A' and the encryption process transformed it into 'G,' the letter 'G' would light up.
8.	Dynamic Encryption:
With each keypress, the rotors advanced, altering the internal wiring pathways. This dynamic nature ensured that the same letter pressed multiple times would result in different encrypted outputs each time, significantly enhancing security.
9.	Decryption:
To decrypt a message, the receiver needed an Enigma machine configured identically to the sender’s. When the encrypted text was typed into the machine, it followed the same encryption steps in reverse, ultimately revealing the original plain text.
 
The combination of plugboard mappings, rotor configurations, stepping mechanics, and the reflector created an astronomical number of possible encryption combinations, making the Enigma seem unbreakable at the time. However, small design flaws and procedural mistakes allowed the Allies to crack its code, revealing critical wartime communications.



Modernized enigma ARTY S7:
Project Components and Design
1. FPGA Controller (Arty S7)
2. Keyboard Design
3. Light-Up Board for Output
4. Onshape for casing

1. FPGA Controller (Arty S7)
The Arty S7 FPGA functions as the main computational unit, responsible for handling encryption logic. Each key press is received by the FPGA, which processes it according to the Enigma’s rotor, plugboard, and reflector configuration, as detailed below.
•	Rotor Configuration: Virtual rotors are programmed within the FPGA as lookup tables, allowing each letter’s transformation to be dynamically altered with every keystroke.
•	Plugboard Simulation: A key feature of the Enigma machine, the plugboard adds an extra layer of encryption. This project implements a configurable plugboard in Verilog to replicate the swapping of character pairs.
•	Reflector: The reflector adds complexity by sending the electrical signal back through the rotors, doubling the encryption. This component is implemented with a lookup table, consistent with historical Enigma functionality.
 




2. Keyboard Design
The custom-designed keyboard uses a 9x4 matrix setup, resembling the Enigma’s key arrangement. Each key press is detected via multiplexers (74HC4051),  which scan the matrix for active rows and columns, identifying the pressed key. Each key press is detected via multiplexers (74HC4051), which scan the matrix for active columns, identifying the pressed key with respect to the high column.
•	Matrix Setup: Arranged in rows and columns with for each key, allowing for distinct electrical paths to the FPGA.
•	Multiplexing: The multiplexer allows column-by-column scanning, reducing pin usage while detecting precise key presses.
This design mimics the Enigma’s input system, where each key press initiates the encoding process, thus creating a unique encoded letter output each time.
 


3. Light-Up Board for Output
The output side of the Enigma machine is represented by an LED-based light-up board, which provides real-time visual feedback of encoded letters.
•	LED Array with Multiplexers: The board uses two 16-channel multiplexers to control an array of LEDs, with each LED corresponding to a specific letter. By using multiplexers, we reduced the number of necessary control lines, creating a cleaner design.
•	Letter Representation: The board lights up the LED corresponding to the encoded letter, similar to the lamp board on the original Enigma machine. This visual feedback enhances understanding by offering a direct view of the encryption output.
 




4. CAD Files and Enclosure Design
The keyboard and FPGA case were designed with custom CAD files, providing a stable structure and aesthetic appeal to the project.
•	Keyboard Enclosure: CAD files allow for a matrix-style mount, which can be adjusted in two configurations for top or bottom mounting.
 

Keyboard based on enigma layout for this project. Has space for a full-size breadboard, and can be configured in 2 mounting styles(with additional parts, currently is top-mount). Large parts have been split into two and can be glued together
Components:
•	3dp plate
•	Left top
•	Left bottom
•	Right top
•	Right bottom
 
             

•	FPGA Case: The Arty S7 board is housed in a custom-designed case, providing structural support and protection while allowing visibility of the board’s LED indicators.
 

The cad files can be looked up on MyOwnEnigma/cad at master · KL-Mithunvel/MyOwnEnigma · GitHub


Methodology
1.	Schematic Design: Using KiCad, the project’s schematics were created to ensure proper connections between the keyboard, FPGA, and LED output board. KiCad's simulation tools enabled preliminary testing of each component’s functionality before implementation.
2.	Verilog Programming: Each aspect of the Enigma machine—rotor stepping, plugboard swapping, and reflector logic—was coded in Verilog on the Arty S7. The modular nature of Verilog allowed for efficient coding of complex logic and dynamic rotor movement with each keystroke.
Verilog programming s done in vivado.
3.	Assembly and Testing: The components were assembled, and the full system was tested by inputting characters through the keyboard and observing the LED light-up output for each encoded letter. Debugging and refinements were made to achieve reliable output that matched expected encryption patterns

 
Results
The FPGA-based Enigma machine successfully replicates the cryptographic functions of its historical counterpart. The FPGA processes each input, steps the rotors, and displays the encoded letter via the light-up board. 
Users experience real-time encryption as they interact with the machine, making the complexity of Enigma encryption accessible.


The project meets its objective of creating an interactive replica, with each keystroke translating into a unique encrypted letter, faithfully emulating the behaviour of an Enigma machine. The visual feedback via LEDs enhances user engagement and understanding of the machine’s inner workings.


Discussion
This project showcases the versatility of FPGA technology in implementing complex cryptographic devices. By translating each component of the Enigma machine into digital logic, we recreated a historical device with modern hardware, offering both educational value and practical insights into encryption. Key learning areas include:
•	Digital Logic Design: Gained expertise in digital design and implementing complex logic with FPGAs.
•	Hardware-Software Integration: Developed skills in hardware interfacing through the use of custom-built components.
•	Cryptographic Principles: Applied historical cryptographic concepts in a modern digital framework.

Conclusion
The FPGA-based Enigma machine is a functional replica that brings historical encryption techniques to life. Through the integration of custom hardware and FPGA programming, this project illustrates the power of digital logic in recreating sophisticated cryptographic processes. The hands-on nature of the project provides valuable learning opportunities in FPGA design, digital logic, and encryption fundamentals.
________________________________________
References
•	encryption - How does the ring settings of enigma change wiring tables? - Cryptography Stack Exchange
•	Enigma Tech Details
•	https://www.cs.cornell.edu/courses/cs3110/2020fa/a1/
•	 https://youtu.be/G2_Q9FoD-oQ?feature=shared
•	 https://www.ciphermachinesandcryptology.com/en/enigmatech.htm
•	 https://www.cryptomuseum.com/crypto/enigma/msg/p1030681.htm


________________________________________


https://digilent.com/reference/_media/programmable-logic/arty-s7/arty-s7-e2-sch.pdf
https://www.emo.org.tr/ekler/a70aa1cbbf26e9c_ek.pdf
https://mm.digikey.com/Volume0/opasdata/d220001/medias/docus/2280/410-352_Web.pdf
https://www.ciphermachinesandcryptology.com/en/enigmatech.htm
