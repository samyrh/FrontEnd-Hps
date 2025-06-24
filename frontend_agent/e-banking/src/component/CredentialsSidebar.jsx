// src/component/CredentialsSidebar.jsx
import { Box, VStack, Text, Icon, Flex } from '@chakra-ui/react';
import { FaUser, FaCreditCard, FaBell } from 'react-icons/fa';

const items = [
    { icon: FaUser, label: 'Personal Information', key: 'personal' },
    { icon: FaCreditCard, label: 'Billing', key: 'billing' },
    { icon: FaBell, label: 'Notifications', key: 'notifications' },
];

export default function CredentialsSidebar({ selectedSection, onSelect }) {
    return (
        <Box w="260px" pr="8">
            <Text fontSize="lg" fontWeight="bold" mb="6" color="gray.400">
                Credentials
            </Text>
            <VStack align="stretch" spacing="4">
                {items.map((item, index) => {
                    const isActive = selectedSection === item.key;
                    return (
                        <Flex
                            key={item.label}
                            align="center"
                            gap="10px"
                            px="4"
                            py="2"
                            bg={isActive ? 'purple.700' : 'transparent'}
                            color={isActive ? 'white' : 'gray.400'}
                            borderRadius="md"
                            cursor="pointer"
                            _hover={{ bg: 'purple.600', color: 'white' }}
                            onClick={() => onSelect(item.key)}
                        >
                            <Icon as={item.icon} />
                            <Text>{item.label}</Text>
                        </Flex>
                    );
                })}
            </VStack>
        </Box>
    );
}
