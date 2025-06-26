// src/component/PersonalInfos.jsx
import {
    Box,
    Flex,
    FormControl,
    FormLabel,
    Input,
    Text,
    Button,
    Icon,
    useColorModeValue,
} from '@chakra-ui/react';
import { FaUser, FaEnvelope, FaLock } from 'react-icons/fa';
import { useState } from 'react';

export default function PersonalInfos() {
    const [generatedPassword, setGeneratedPassword] = useState('');

    const generatePassword = () => {
        const charset = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#$%^&*()';
        const password = Array.from({ length: 12 }, () =>
            charset[Math.floor(Math.random() * charset.length)]
        ).join('');
        setGeneratedPassword(password);
    };

    return (
        <Box borderRadius="20px" p="6" bg={useColorModeValue('white', '#141f52')}>
            <Text fontSize="lg" fontWeight="bold" mb="2">Personal Information</Text>
            <Text fontSize="sm" color="gray.400" mb="6">Please enter the user's details.</Text>

            <Flex direction="column" gap="24px">
                <FormControl>
                    <FormLabel><Icon as={FaUser} mr="2" />Full name</FormLabel>
                    <Input placeholder="Enter full name" />
                </FormControl>

                <FormControl>
                    <FormLabel><Icon as={FaEnvelope} mr="2" />Email address</FormLabel>
                    <Input placeholder="Enter email" />
                </FormControl>

                <FormControl>
                    <FormLabel><Icon as={FaLock} mr="2" />Password</FormLabel>
                    <Flex gap="12px">
                        <Input value={generatedPassword} readOnly placeholder="Click to generate a password" />
                        <Button colorScheme="purple" onClick={generatePassword}>Generate</Button>
                    </Flex>
                </FormControl>

                {/* Add User Button */}
                <Flex justify="center" mt="20px">
                    <Button colorScheme="purple" size="lg" px="10">
                        Add User
                    </Button>
                </Flex>
            </Flex>
        </Box>
    );
}
