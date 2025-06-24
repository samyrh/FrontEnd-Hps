import { Box, Flex, Icon, Text, useColorModeValue } from '@chakra-ui/react';
import {
    CheckCircle,
    Shield,
    Lock,
    AlertCircle,
    CircleSlash,
} from 'lucide-react';

const StatusCard = ({ label, count, icon }) => {
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
            minH="120px"
            w="220px"
            boxShadow={useColorModeValue('0 4px 12px rgba(0,0,0,0.06)', 'md')}
            transition="all 0.2s ease-in-out"
            _hover={{
                boxShadow: 'xl',
                transform: 'translateY(-4px)',
            }}
            cursor="pointer"
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
                        {count}
                    </Text>
                </Box>
            </Flex>
        </Box>
    );
};

export default function CardSummaryPanel() {
    return (
        <Box overflowX="auto" w="100%">
            <Flex gap={6} wrap="nowrap" justify="center" minW="1200px">
                <StatusCard label="Active" count={245} icon={CheckCircle} />
                <StatusCard label="Temporarily Blocked" count={38} icon={Shield} />
                <StatusCard label="Security Blocked" count={12} icon={Lock} />
                <StatusCard label="Fraud Blocked" count={7} icon={AlertCircle} />
                <StatusCard label="Permanently Blocked" count={54} icon={CircleSlash} />
            </Flex>
        </Box>
    );
}
