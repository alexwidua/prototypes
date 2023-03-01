import React from "react";

export default function CursorSVG({ text }) {
  return !text ? (
    <svg
      width="100%"
      height="100%"
      viewBox="0 0 18 24"
      fill="none"
      xmlns="http://www.w3.org/2000/svg"
    >
      <g filter="url(#filter0_d_0_110)">
        <path
          d="M3 2V18.015L6.22455 14.8836L8.47949 20.2243L12.0845 18.6893L9.98413 13.619H14.591L3 2Z"
          fill="white"
        />
        <path
          d="M4 15.5951V4.4071L12.165 12.5901H8.47119L10.751 18.0086L8.90698 18.7826L6.53729 13.1458L4 15.5951Z"
          fill="black"
        />
      </g>
      <defs>
        <filter
          id="filter0_d_0_110"
          x="0.4"
          y="0.4"
          width="16.791"
          height="23.4243"
          filterUnits="userSpaceOnUse"
          colorInterpolationFilters="sRGB"
        >
          <feFlood floodOpacity="0" result="BackgroundImageFix" />
          <feColorMatrix
            in="SourceAlpha"
            type="matrix"
            values="0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 127 0"
            result="hardAlpha"
          />
          <feOffset dy="1" />
          <feGaussianBlur stdDeviation="1.3" />
          <feColorMatrix
            type="matrix"
            values="0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0.32 0"
          />
          <feBlend
            mode="normal"
            in2="BackgroundImageFix"
            result="effect1_dropShadow_0_110"
          />
          <feBlend
            mode="normal"
            in="SourceGraphic"
            in2="effect1_dropShadow_0_110"
            result="shape"
          />
        </filter>
      </defs>
    </svg>
  ) : (
    <svg
      width="15"
      height="24"
      viewBox="0 0 15 24"
      fill="none"
      xmlns="http://www.w3.org/2000/svg"
    >
      <g filter="url(#filter0_d_8170_1569)">
        <g filter="url(#filter1_d_8170_1569)">
          <path
            fillRule="evenodd"
            clipRule="evenodd"
            d="M7.02629 5.7633V10.0045H6.02309V11.0045H7.02629V16.1339C6.57739 17.3623 5.33677 18.0647 4.04617 18.0051L4 19.004C5.34784 19.0663 6.71576 18.4801 7.51322 17.3454C8.30196 18.4929 9.72439 19.0651 11.0462 19.004L11 18.0051C9.70427 18.0649 8.41684 17.3559 8.02629 16.1439V11.0045H9.02309V10.0045H8.02629V5.7529C8.41346 4.55283 9.66692 3.94237 11 4.00399L11.0462 3.00505C9.73769 2.94457 8.3016 3.42457 7.50674 4.56703C6.69787 3.47112 5.30064 2.94493 4 3.00505L4.04617 4.00399C5.33343 3.94449 6.5964 4.60196 7.02629 5.7633Z"
            fill="black"
          />
          <path
            d="M7.49814 3.79654C6.55882 2.87088 5.2167 2.44828 3.97691 2.50559L3.47745 2.52867L3.50053 3.02814L3.54671 4.02707L3.56979 4.52654L4.06926 4.50345C5.16423 4.45284 6.16169 4.99621 6.52629 5.85841V9.50452H6.02309H5.52309V10.0045V11.0045V11.5045H6.02309H6.52629V16.0408C6.13939 16.9872 5.14577 17.5553 4.06926 17.5056L3.56979 17.4825L3.54671 17.982L3.50053 18.9809L3.47745 19.4804L3.97691 19.5035C5.26859 19.5632 6.59023 19.0889 7.51112 18.1317C8.44168 19.1017 9.80635 19.5618 11.0693 19.5035L11.5687 19.4804L11.5456 18.9809L11.4995 17.982L11.4764 17.4825L10.9769 17.5056C9.87892 17.5563 8.85966 16.9693 8.52629 16.0605V11.5045H9.02309H9.52309V11.0045V10.0045V9.50452H9.02309H8.52629V5.83654C8.84764 4.96583 9.81343 4.44968 10.9769 4.50346L11.4764 4.52654L11.4995 4.02708L11.5456 3.02814L11.5687 2.52868L11.0693 2.50559C9.83379 2.44848 8.44569 2.83044 7.49814 3.79654Z"
            stroke="white"
          />
        </g>
      </g>
      <defs>
        <filter
          id="filter0_d_8170_1569"
          x="0.354895"
          y="0.4"
          width="14.3364"
          height="23.2085"
          filterUnits="userSpaceOnUse"
          colorInterpolationFilters="sRGB"
        >
          <feFlood floodOpacity="0" result="BackgroundImageFix" />
          <feColorMatrix
            in="SourceAlpha"
            type="matrix"
            values="0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 127 0"
            result="hardAlpha"
          />
          <feOffset dy="1" />
          <feGaussianBlur stdDeviation="1.3" />
          <feColorMatrix
            type="matrix"
            values="0 0 0 0 1 0 0 0 0 1 0 0 0 0 1 0 0 0 0.32 0"
          />
          <feBlend
            mode="normal"
            in2="BackgroundImageFix"
            result="effect1_dropShadow_8170_1569"
          />
          <feBlend
            mode="normal"
            in="SourceGraphic"
            in2="effect1_dropShadow_8170_1569"
            result="shape"
          />
        </filter>
        <filter
          id="filter1_d_8170_1569"
          x="0.354895"
          y="0.400115"
          width="14.3364"
          height="23.2083"
          filterUnits="userSpaceOnUse"
          colorInterpolationFilters="sRGB"
        >
          <feFlood floodOpacity="0" result="BackgroundImageFix" />
          <feColorMatrix
            in="SourceAlpha"
            type="matrix"
            values="0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 127 0"
            result="hardAlpha"
          />
          <feOffset dy="1" />
          <feGaussianBlur stdDeviation="1.3" />
          <feComposite in2="hardAlpha" operator="out" />
          <feColorMatrix
            type="matrix"
            values="0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0.32 0"
          />
          <feBlend
            mode="normal"
            in2="BackgroundImageFix"
            result="effect1_dropShadow_8170_1569"
          />
          <feBlend
            mode="normal"
            in="SourceGraphic"
            in2="effect1_dropShadow_8170_1569"
            result="shape"
          />
        </filter>
      </defs>
    </svg>
  );
}
