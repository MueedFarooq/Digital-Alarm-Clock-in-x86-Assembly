# Digital Alarm Clock in x86 Assembly

A real-time digital alarm clock built with x86 Assembly language for DOS. Set alarms and get audio alerts through your PC speaker!

## 🚀 Features

- Real-time clock display (HH:MM:SS)
- Set custom alarm times
- Audio alarm with PC speaker beeps
- Simple keyboard controls
- Runs in DOS/DOSBox

## 🛠️ Quick Start

### Requirements
- MASM assembler
- DOSBox (recommended)

### Setup & Run
```bash
# Assemble the code
masm alarm_clock.asm
link alarm_clock.obj

# Run in DOSBox
alarm_clock.exe
```

## 🎮 How to Use

1. **View Time**: Current time displays automatically
2. **Set Alarm**: Enter time when prompted (HH:MM format)
3. **Wait**: Program will beep when alarm time is reached
4. **Exit**: Press ESC to quit

### Display:

<img width="350" height="289" alt="image" src="https://github.com/user-attachments/assets/848040c9-0c18-496d-9b92-fa45b306ff04" />

<img width="437" height="355" alt="image" src="https://github.com/user-attachments/assets/f8d34183-88bc-4cf8-81ca-aae87a71b4b9" />

<img width="464" height="210" alt="image" src="https://github.com/user-attachments/assets/ad9d5faf-81d9-4f71-b382-ef9c17bfdd2c" />



## 🔧 Technical Details

**Built with:**
- x86 Assembly (real-mode)
- DOS interrupts (`int 21h` for time, `int 10h` for display)
- Direct hardware access for PC speaker
- Modular code structure

**Key Components:**
- Time reading from system clock
- Alarm comparison logic
- PC speaker sound generation
- Real-time display updates

## 📝 Code Structure

- `get_time`: Reads system time
- `set_alarm`: Handles user input
- `check_alarm`: Compares times
- `trigger_alarm`: Sounds alarm
- `make_beep`: PC speaker control

Perfect for learning assembly language and hardware programming!

## 🎯 Learning Focus

This project demonstrates:
- Low-level hardware interaction
- BIOS/DOS interrupt programming
- Real-time system concepts
- Assembly language structure
