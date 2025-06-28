// src/component/BasicInfos.jsx
import {
    Box, FormControl, FormLabel, Input, Text, useColorModeValue
} from '@chakra-ui/react';

export default function BasicInfos() {
    const border = useColorModeValue('gray.200', 'whiteAlpha.200');

    return (
        <Box borderRadius="20px" p="6" bg={useColorModeValue('white', '#141f52')}>
            <Text fontSize="lg" fontWeight="bold" mb="2">Basic information</Text>
            <Text fontSize="sm" color="gray.400" mb="8">Lorem ipsum dolor sit amet consectetur adipiscing.</Text>

            <FormControl mb="4">
                <FormLabel>Phone</FormLabel>
                <Input placeholder="(123) 456 - 7890" />
            </FormControl>

            <FormControl mb="4">
                <FormLabel>Position</FormLabel>
                <Input placeholder="CEO & Founder" />
            </FormControl>

            <FormControl mb="4">
                <FormLabel>Location</FormLabel>
                <Input placeholder="New York, NY" />
            </FormControl>

            <FormControl>
                <FormLabel>Website</FormLabel>
                <Input placeholder="dashhark.com" />
            </FormControl>
        </Box>
    );
}
