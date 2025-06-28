// src/component/PersonalInfos.jsx
import {
    Box, Flex, FormControl, FormLabel, Input,
    Text, Button, Icon, useColorModeValue,
} from '@chakra-ui/react';
import { FaUser, FaEnvelope, FaLock } from 'react-icons/fa';
import { useEffect, useState } from 'react';

export default function PersonalInfos({ onTimeout, onPartialInput }) {
    const [fullName, setFullName] = useState('');
    const [email, setEmail] = useState('');
    const [generatedPassword, setGeneratedPassword] = useState('');
    const [displayPassword, setDisplayPassword] = useState('');
    const [isButtonDisabled, setIsButtonDisabled] = useState(true);

    useEffect(() => {
        const timer = setTimeout(() => {
            onTimeout(); // hide form
        }, 2 * 60 * 1000); // 2 minutes

        return () => clearTimeout(timer);
    }, [onTimeout]);

    useEffect(() => {
        const filled = [
            fullName.trim() !== '',
            email.trim() !== '',
            generatedPassword.trim() !== '',
        ];
        const count = filled.filter(Boolean).length;
        setIsButtonDisabled(count < 3);

        onPartialInput(count); // notify parent
    }, [fullName, email, generatedPassword]);

    const generatePassword = () => {
        const charset = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#$%^&*()';
        const password = Array.from({ length: 12 }, () =>
            charset[Math.floor(Math.random() * charset.length)]
        ).join('');
        setGeneratedPassword(password);
        setDisplayPassword('************');
    };

    return (
        <Box borderRadius="20px" p="6" bg={useColorModeValue('white', '#141f52')}>
            <Text fontSize="lg" fontWeight="bold" mb="2">Personal Information</Text>
            <Text fontSize="sm" color="gray.400" mb="6">Please enter the user's details.</Text>

            <Flex direction="column" gap="24px">
                <FormControl>
                    <FormLabel><Icon as={FaUser} mr="2" />Full name</FormLabel>
                    <Input value={fullName} onChange={(e) => setFullName(e.target.value)} />
                </FormControl>

                <FormControl>
                    <FormLabel><Icon as={FaEnvelope} mr="2" />Email address</FormLabel>
                    <Input value={email} onChange={(e) => setEmail(e.target.value)} />
                </FormControl>

                <FormControl>
                    <FormLabel><Icon as={FaLock} mr="2" />Password</FormLabel>
                    <Flex gap="12px">
                        <Input type="password" value={displayPassword} readOnly />
                        <Button colorScheme="purple" onClick={generatePassword}>Generate</Button>
                    </Flex>
                </FormControl>

                <Flex justify="center" mt="20px">
                    <Button colorScheme="purple" size="lg" px="10" isDisabled={isButtonDisabled}>
                        Add User
                    </Button>
                </Flex>
            </Flex>
        </Box>
    );
}
