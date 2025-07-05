// src/component/Popup.jsx
import {
    Flex,
    Box,
    Text,
    Icon,
    CloseButton,
} from '@chakra-ui/react';
import { FaRegHandPeace } from 'react-icons/fa';

export default function Popup({ onClose }) {
    // Fixed peachy colors
    const bg = '#FFF5EC';         // Main background
    const iconBg = '#FFE8D9';     // Icon background
    const iconColor = '#DD6B20';  // Icon orange
    const titleColor = '#1A202C'; // Dark text
    const descColor = '#4A5568';  // Gray text

    return (
        <Flex
            position="fixed"
            top="24px"
            left="50%"
            transform="translateX(-50%)"
            bg={bg}
            borderRadius="12px"
            p="14px 16px"
            align="center"
            zIndex="9999"
            minW="320px"
            maxW="90vw"
            boxShadow="sm"
        >
            <Box
                bg={iconBg}
                borderRadius="full"
                p="6px"
                display="flex"
                alignItems="center"
                justifyContent="center"
                mr="12px"
            >
                <Icon as={FaRegHandPeace} boxSize={4} color={iconColor} />
            </Box>

            <Box flex="1">
                <Text fontWeight="semibold" fontSize="sm" color={titleColor} mb="1px">
                    Almost done!
                </Text>
                <Text fontSize="xs" color={descColor}>
                    Complete registration to finish adding the user.
                </Text>
            </Box>

            <CloseButton
                onClick={onClose}
                ml="8px"
                size="sm"
                color={descColor}
            />
        </Flex>
    );
}
