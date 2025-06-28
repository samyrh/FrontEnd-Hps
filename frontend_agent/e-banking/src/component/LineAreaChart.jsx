// src/component/LineChart.jsx
import React from "react";
import { useColorModeValue } from "@chakra-ui/react";
import ReactApexChart from "react-apexcharts";

const LineChart = () => {
    const lineColor = useColorModeValue('#7551FF', '#7551FF');
    const fillColor = useColorModeValue('#E9D8FD', '#1a1f3c');
    const textColor = useColorModeValue('#2D3748', '#EDF2F7');
    const gridColor = useColorModeValue('#EDF2F7', '#1A202C');

    const chartOptions = {
        chart: {
            toolbar: { show: false },
            zoom: { enabled: false },
            foreColor: textColor,
        },
        stroke: {
            curve: 'smooth',
            width: 3,
        },
        fill: {
            type: 'gradient',
            gradient: {
                shade: 'light',
                gradientToColors: [lineColor],
                shadeIntensity: 1,
                type: 'vertical',
                opacityFrom: 0.4,
                opacityTo: 0.1,
                stops: [0, 100],
            },
        },
        colors: [lineColor],
        xaxis: {
            categories: ['SEP', 'OCT', 'NOV', 'DEC', 'JAN', 'FEB'],
            labels: { style: { colors: textColor } },
        },
        yaxis: {
            labels: { style: { colors: textColor } },
        },
        grid: {
            borderColor: gridColor,
            strokeDashArray: 5,
        },
    };

    const chartData = [
        {
            name: "Spent",
            data: [28, 50, 36, 60, 42, 70],
        },
        {
            name: "Budget",
            data: [20, 40, 30, 45, 35, 60],
        },
    ];

    return (
        <ReactApexChart
            options={chartOptions}
            series={chartData}
            type="area"
            width="100%"
            height="100%"
        />
    );


};

export default LineChart;
