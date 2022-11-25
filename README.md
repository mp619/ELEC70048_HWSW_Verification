# ELEC70048_HWSW_Verification

## Hardware

### GPIO - TODO

- [ ] Verification Checklist
- [ ] Parity Bit inplementation
    - [ ] Fault injection
    - [x] Output PARITYERR 'Set to a ‘1’ every time a parity error is detected'
    - [x] Input PARITYSEL 'Parity selection input pin;
                            Odd parity if PARITYSEL = 1,
                            Even parity if PARITYSEL = 0'
- [ ] Function Verification
    - [ ] Add Assertions
    - [ ] Test with JasperGold
- [ ] Unit Level Tests
    - [x] Get GPIO Read/Write to work for initial tests
    - [x] Implement transaction class to randomize
    - [x] Implement Generator class
    - [x] Implement Driver class
    - [x] Make a checker
    - [] Check coverage
- [ ] Top coverage with CPU implementation 
 
### VGA - TODO

- [ ] Verification Checklist
- [ ] Dual Lock-Step Configuration of VGA Peripheral

## Software
