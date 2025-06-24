// src/component/PersonalInfos.jsx
import {
    Box, Flex, FormControl, FormLabel, Input, Textarea, Text, Avatar, Button, Icon,
    useColorModeValue
} from '@chakra-ui/react';
import { FaUser, FaEnvelope, FaImage, FaEdit } from 'react-icons/fa';

export default function PersonalInfos() {
    return (
        <Box borderRadius="20px" p="6" bg={useColorModeValue('white', '#141f52')}>
            <Text fontSize="lg" fontWeight="bold" mb="2">Personal information</Text>
            <Text fontSize="sm" color="gray.400" mb="6">Lorem ipsum dolor sit amet consectetur adipiscing.</Text>

            <Flex direction="column" gap="24px">
                <FormControl>
                    <FormLabel><Icon as={FaUser} mr="2" />Full name</FormLabel>
                    <Input defaultValue="John Carter" />
                </FormControl>

                <FormControl>
                    <FormLabel><Icon as={FaEnvelope} mr="2" />Email address</FormLabel>
                    <Input defaultValue="john@dashdark.com" />
                </FormControl>

                <FormControl>
                    <FormLabel><Icon as={FaImage} mr="2" />Photo</FormLabel>
                    <Flex gap="20px" align="center">
                        <Avatar name="John Carter" src="https://i.pravatar.cc/150?img=12" />
                        <Button size="sm" variant="ghost" colorScheme="red">Delete</Button>
                        <Box textAlign="center">
                            <Text color="purple.400" fontSize="sm" cursor="pointer">Click to upload</Text>
                            <Text fontSize="xs" color="gray.500">SVG, PNG, JPG or GIF (max. 800x400px)</Text>
                        </Box>
                    </Flex>
                </FormControl>

                <FormControl>
                    <FormLabel><Icon as={FaEdit} mr="2" />Short description</FormLabel>
                    <Textarea placeholder="Write a short bio about you..." />
                </FormControl>
            </Flex>
        </Box>
    );
}
