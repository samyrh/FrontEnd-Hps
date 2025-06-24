import { Box, Flex, Icon, Text, useColorModeValue } from '@chakra-ui/react';

export default function StatCard({ label, value, icon }) {
    const cardBg = useColorModeValue('white', '#18214a');
    const textColor = useColorModeValue('#1A202C', 'white');
    const subTextColor = useColorModeValue('gray.500', 'gray.400');
    const iconBg = useColorModeValue('#E9D8FD', '#1a1f3c');
    const iconColor = useColorModeValue('#7551FF', 'white');

    return (
        <Box
            bg={cardBg}
            p="24px"
            borderRadius="20px"
            minH="120px" // increased height
            boxShadow={useColorModeValue('0 4px 12px rgba(0,0,0,0.06)', 'md')}
            w="100%" // stretch to container
        >
            <Flex align="center" gap="16px">
                <Box
                    bg={iconBg}
                    borderRadius="full"
                    p="12px"
                    display="flex"
                    alignItems="center"
                    justifyContent="center"
                >
                    <Icon as={icon} boxSize={7} color={iconColor} />
                </Box>
                <Box>
                    <Text fontSize="md" color={subTextColor}>
                        {label}
                    </Text>
                    <Text fontSize="2xl" fontWeight="bold" color={textColor}>
                        {value}
                    </Text>
                </Box>
            </Flex>
        </Box>
    );
}
