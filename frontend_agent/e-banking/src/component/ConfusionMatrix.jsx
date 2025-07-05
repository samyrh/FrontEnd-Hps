import React from "react";
import {
    Box,
    Table,
    Thead,
    Tbody,
    Tr,
    Th,
    Td,
    useColorModeValue,
    Text,
} from "@chakra-ui/react";

/**
 * Props:
 * - labels: string[] (e.g., ["Shopping", "Travel", "Entertainment"])
 * - matrix: number[][] (e.g., [[15,2,0],[1,18,1],[0,1,20]])
 */
export default function ConfusionMatrix({ labels, matrix }) {
    const containerBg = useColorModeValue("white", "#141f52");
    const textColor = useColorModeValue("gray.700", "white");

    const maxVal = Math.max(...matrix.flat());

    return (
        <Box
            bg={containerBg}
            p="6"
            borderRadius="lg"
            boxShadow="lg"
            overflowX="auto"
        >
            <Text mb="4" fontSize="lg" fontWeight="bold" color={textColor}>
                Confusion Matrix
            </Text>
            <Table variant="simple" size="sm">
                <Thead>
                    <Tr>
                        <Th></Th>
                        {labels.map((label) => (
                            <Th key={label} color={textColor}>
                                {label}
                            </Th>
                        ))}
                    </Tr>
                </Thead>
                <Tbody>
                    {matrix.map((row, rowIdx) => (
                        <Tr key={rowIdx}>
                            <Th color={textColor}>{labels[rowIdx]}</Th>
                            {row.map((cell, colIdx) => {
                                const opacity = cell === 0 ? 0 : 0.2 + (cell / maxVal) * 0.8;
                                return (
                                    <Td
                                        key={colIdx}
                                        bg={`rgba(117, 81, 255, ${opacity})`}
                                        color={textColor}
                                        textAlign="center"
                                        fontWeight="bold"
                                    >
                                        {cell}
                                    </Td>
                                );
                            })}
                        </Tr>
                    ))}
                </Tbody>
            </Table>
        </Box>
    );
}
