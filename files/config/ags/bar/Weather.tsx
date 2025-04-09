import { interval, execAsync } from "astal";

type HourlyWeatherData = {
  DewPointC: string;
  DewPointF: string;
  FeelsLikeC: string;
  FeelsLikeF: string;
  HeatIndexC: string;
  HeatIndexF: string;
  WindChillC: string;
  WindChillF: string;
  WindGustKmph: string;
  WindGustMiles: string;
  chanceoffog: string;
  chanceoffrost: string;
  chanceofhightemp: string;
  chanceofovercast: string;
  chanceofrain: string;
  chanceofremdry: string;
  chanceofsnow: string;
  chanceofsunshine: string;
  chanceofthunder: string;
  chanceofwindy: string;
  cloudcover: string;
  diffRad: string;
  humidity: string;
  precipInches: string;
  precipMM: string;
  pressure: string;
  pressureInches: string;
  shortRad: string;
  tempC: string;
  tempF: string;
  time: string;
  uvIndex: string;
  visibility: string;
  visibilityMiles: string;
  weatherCode: number;
  weatherDesc: { value: string }[];
  weatherIconUrl: { value: string }[];
  winddir16Point: string;
  winddirDegree: string;
  windspeedKmph: string;
  windspeedMiles: string;
};

type WeatherData = {
  current_condition: {
    FeelsLikeC: string;
    FeelsLikeF: string;
    cloudcover: string;
    humidity: string;
    localObsDateTime: string;
    observation_time: string;
    precipInches: string;
    precipMM: string;
    pressure: string;
    pressureInches: string;
    temp_C: string;
    temp_F: string;
    uvIndex: string;
    visibility: string;
    visibilityMiles: string;
    weatherCode: number;
    weatherDesc: { value: string }[];
    weatherIconUrl: { value: string }[];
    winddir16Point: string;
    winddirDegree: string;
    windspeedKmph: string;
    windspeedMiles: string;
  }[];
  nearest_area: {
    areaName: { value: string }[];
    country: { value: string }[];
    latitude: string;
    longitude: string;
    region: { value: string }[];
  }[];
  request: {
    query: string;
    type: string;
  }[];
  weather: {
    astronomy: {
      moon_illumination: string;
      moon_phase: string;
      moonrise: string;
      moonset: string;
      sunrise: string;
      sunset: string;
    }[];
    avgtempC: string;
    avgtempF: string;
    date: string;
    hourly: HourlyWeatherData[];
    maxtempC: string;
    maxtempF: string;
    mintempC: string;
    mintempF: string;
    sunHour: string;
    totalSnow_cm: string;
    uvIndex: string;
  }[];
};

const WEATHER_CODES: {
  [key: number]: string;
} = {
  113: " ",
  116: " ",
  119: " ",
  122: " ",
  143: " ",
  176: " ",
  179: " ",
  182: " ",
  185: " ",
  200: " ",
  227: " ",
  230: " ",
  248: " ",
  260: " ",
  263: " ",
  266: " ",
  281: " ",
  284: " ",
  293: " ",
  296: " ",
  299: " ",
  302: " ",
  305: " ",
  308: " ",
  311: " ",
  314: " ",
  317: " ",
  320: " ",
  323: " ",
  326: " ",
  329: " ",
  332: " ",
  335: " ",
  338: " ",
  350: " ",
  353: " ",
  356: " ",
  359: " ",
  362: " ",
  365: " ",
  368: " ",
  371: " ",
  374: " ",
  377: " ",
  386: " ",
  389: " ",
  392: " ",
  395: " ",
};

const formatTime = (time: string) => time.replace("00", "").padStart(2, "0");

const formatTemp = (temp: string) => `${temp}°`.padEnd(3);

const formatChances = (hour: HourlyWeatherData) => {
  const chances: { [key in keyof HourlyWeatherData]?: string } = {
    chanceoffog: "Fog",
    chanceoffrost: "Frost",
    chanceofovercast: "Overcast",
    chanceofrain: "Rain",
    chanceofsnow: "Snow",
    chanceofsunshine: "Sunshine",
    chanceofthunder: "Thunder",
    chanceofwindy: "Wind",
  };

  let conditions = [];
  for (let event in chances) {
    const value = hour[event as keyof HourlyWeatherData];
    if (typeof value === "string" && parseInt(value) > 0) {
      conditions.push(`${chances[event as keyof HourlyWeatherData]} ${value}%`);
    }
  }
  return conditions.join(", ");
};

export function Weather() {
  const self = (
    <label className="weather" label="󰼯" tooltipMarkup="Wttr.in fetch error." />
  );

  interval(300000, () => {
    execAsync("curl -s wttr.in/Lancaster,+New+York?format=j1")
      .then((res: string) => {
        const weatherData: WeatherData = JSON.parse(res);
        const output: { text: string; tooltip: string } = {
          text: "",
          tooltip: "",
        };
        output["text"] =
          WEATHER_CODES[weatherData["current_condition"][0]["weatherCode"]] +
          " " +
          weatherData["current_condition"][0]["FeelsLikeF"] +
          "°";

        output["tooltip"] =
          `<b>${weatherData["current_condition"][0]["weatherDesc"][0]["value"]} ${weatherData["current_condition"][0]["temp_C"]}°</b>\n`;
        output["tooltip"] +=
          `Feels like: ${weatherData["current_condition"][0]["FeelsLikeF"]}°\n`;
        output["tooltip"] +=
          `Wind: ${weatherData["current_condition"][0]["windspeedKmph"]}Km/h\n`;
        output["tooltip"] +=
          `Humidity: ${weatherData["current_condition"][0]["humidity"]}%\n`;

        weatherData["weather"].forEach((day, i) => {
          output["tooltip"] += `\n<b>`;
          if (i === 0) {
            output["tooltip"] += "Today, ";
          } else if (i === 1) {
            output["tooltip"] += "Tomorrow, ";
          }
          output["tooltip"] += `${day["date"]}</b>\n`;
          output["tooltip"] += ` ${day["maxtempC"]}°  ${day["mintempC"]}° `;
          output["tooltip"] +=
            `  ${day["astronomy"][0]["sunrise"]}  ${day["astronomy"][0]["sunset"]}\n`;

          day["hourly"].forEach((hour) => {
            let currentHour = new Date().getHours();
            if (
              i === 0 &&
              parseInt(formatTime(hour["time"])) < currentHour - 2
            ) {
              return;
            }
            output["tooltip"] +=
              `${formatTime(hour["time"])} ${WEATHER_CODES[hour["weatherCode"]]} ${formatTemp(hour["FeelsLikeF"])} ${hour["weatherDesc"][0]["value"]}, ${formatChances(hour)}\n`;
          });
        });
        self.set_property("label", output["text"]);
        self.set_tooltip_markup(output["tooltip"]);
      })
      .catch(console.error);
  });

  return self;
}
